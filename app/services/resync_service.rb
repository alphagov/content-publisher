# frozen_string_literal: true
require 'damerau-levenshtein'

class ResyncService < ApplicationService
  attr_reader :document

  delegate :live_edition,
           :current_edition,
           to: :document

  def initialize(document)
    @document = document
  end

  def call
    Edition.transaction do
      sync_live_edition if live_edition
      sync_draft_edition if current_edition != live_edition
    end
  end

private

  def sync_live_edition
    live_edition.lock!
    set_political_and_government(live_edition)
    reserve_path(live_edition.base_path)

    proposed_edition = PreviewService::Payload.new(live_edition, republish: true).payload
    edition_in_publishing_api = GdsApi.publishing_api.get_content(live_edition.content_id).to_h

    if edition_in_publishing_api.publication_state != "published"
      version = latest_content_item[:state_history].select { |_, hash| hash["published"] }
      published_version = version.keys.first.to_i

      edition_in_publishing_api = GdsApi.publishing_api.get_content(live_edition.content_id, version: published_version).to_h
    end

    raise WhitehallImporter::AbortImportError unless versions_match?(edition_in_publishing_api, proposed_edition)

    PreviewService.call(live_edition, republish: true)
    PublishAssetService.call(live_edition, nil)

    if live_edition.withdrawn?
      withdraw
    elsif live_edition.removed?
      redirect_or_remove
    else
      publish
    end
  end

  def sync_draft_edition
    current_edition.lock!
    set_political_and_government(current_edition)
    reserve_path(current_edition.base_path)

    proposed_edition = PreviewService::Payload.new(current_edition).payload
    edition_in_publishing_api = GdsApi.publishing_api.get_content(current_edition.content_id).to_h

    raise WhitehallImporter::AbortImportError unless versions_match?(edition_in_publishing_api, proposed_edition)

    FailsafePreviewService.call(current_edition)

    schedule if current_edition.scheduled?
  end

  def set_political_and_government(edition)
    repository = BulkData::GovernmentRepository.new
    government = repository.for_date(edition.public_first_published_at)

    edition.update!(
      revision_synced: false,
      system_political: PoliticalEditionIdentifier.new(edition).political?,
      government_id: government&.content_id,
    )
  end

  def reserve_path(base_path)
    GdsApi.publishing_api.put_path(
      base_path,
      publishing_app: "content-publisher",
      override_existing: true,
    )
  end

  def publish
    GdsApi.publishing_api.publish(
      live_edition.document.content_id,
      nil, # Sending update_type is deprecated (now in payload)
      locale: live_edition.document.locale,
    )
  end

  def withdraw
    withdrawal = live_edition.status.details
    explanation_html = GovspeakDocument.new(withdrawal.public_explanation, live_edition).payload_html

    GdsApi.publishing_api.unpublish(
      live_edition.document.content_id,
      type: "withdrawal",
      explanation: explanation_html,
      locale: live_edition.locale,
      unpublished_at: withdrawal.withdrawn_at,
      allow_draft: true,
    )
  end

  def redirect_or_remove
    removal = live_edition.status.details
    GdsApi.publishing_api.unpublish(
      live_edition.content_id,
      type: removal.redirect? ? "redirect" : "gone",
      explanation: removal.explanatory_note,
      alternative_path: removal.alternative_path,
      locale: live_edition.locale,
      unpublished_at: removal.created_at,
      allow_draft: true,
    )
  end

  def schedule
    payload = ScheduleService::Payload.new(current_edition).intent_payload
    GdsApi.publishing_api.put_intent(current_edition.base_path, payload)

    scheduling = current_edition.status.details
    ScheduledPublishingJob.set(wait_until: scheduling.publish_time)
                          .perform_later(current_edition.id)
  end

  def versions_match?(edition_in_publishing_api, proposed_edition)
    edition_in_publishing_api["base_path"] == proposed_edition["base_path"] &&
      edition_in_publishing_api["title"] == proposed_edition["title"] &&
      edition_in_publishing_api["description"] == proposed_edition["description"] &&
      edition_in_publishing_api["first_published_at"] == proposed_edition["first_published_at"] &&
      edition_in_publishing_api["public_updated_at"] == proposed_edition["public_updated_at"] &&
      edition_in_publishing_api["document_type"] == proposed_edition["document_type"] &&
      edition_in_publishing_api["schema_name"] == proposed_edition["schema_name"] &&
      body_text_similar_enough?(edition_in_publishing_api["details"]["body"],  proposed_edition["details"]["body"])
  end

  def body_text_similar_enough?(pub_api_body, proposed_body)
    # See https://www.rubydoc.info/gems/damerau-levenshtein/1.1.0#API_Description
    DamerauLevenshtein.distance(pub_api_body, proposed_body, 1, 100) < 100
  end
end
