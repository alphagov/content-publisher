# frozen_string_literal: true

class ResyncService < ApplicationService
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def call
    sync_live_edition if document.live_edition
    sync_draft_edition if document.current_edition != document.live_edition
  end

private

  def sync_live_edition
    edition = document.live_edition
    set_political_and_government(edition)
    PreviewService.call(edition, republish: true)
    PublishAssetService.call(edition, nil)

    if edition.withdrawn?
      withdraw(edition)
    elsif edition.removed?
      redirect_or_remove(edition)
    else
      publish(edition)
    end

    edition.update!(revision_synced: true)
  end

  def sync_draft_edition
    edition = document.current_edition
    set_political_and_government(edition)
    PreviewService.call(edition)
  end

  def set_political_and_government(edition)
    Edition.transaction do
      Edition.lock.find(edition.id)
      edition.update!(
        revision_synced: false,
        system_political: PoliticalEditionIdentifier.new(edition).political?,
        government_id: government_id(edition),
      )
    end
  end

  def publish(edition)
    GdsApi.publishing_api_v2.publish(
      edition.document.content_id,
      nil, # Sending update_type is deprecated (now in payload)
      locale: edition.document.locale,
    )
  end

  def withdraw(edition)
    GdsApi.publishing_api_v2.unpublish(
      edition.document.content_id,
      type: "withdrawal",
      explanation: GovspeakDocument.new(edition.status.details, edition).payload_html,
      locale: edition.locale,
    )
  end

  def redirect_or_remove(edition)
    removal = edition.status.details
    GdsApi.publishing_api_v2.unpublish(
      edition.content_id,
      type: removal.redirect? ? "redirect" : "gone",
      explanation: removal.explanatory_note,
      alternative_path: removal.alternative_path,
      locale: edition.locale,
    )
  end

  def government_id(edition)
    government = if edition.public_first_published_at
                   Government.for_date(edition.public_first_published_at)
                 else
                   Government.current
                 end
    government.content_id
  end
end
