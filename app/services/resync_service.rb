# frozen_string_literal: true

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
    PreviewService.call(current_edition)
  end

  def set_political_and_government(edition)
    edition.update!(
      revision_synced: false,
      system_political: PoliticalEditionIdentifier.new(edition).political?,
      government_id: Government.for_date(edition.public_first_published_at)&.content_id,
    )
  end

  def reserve_path(base_path)
    GdsApi.publishing_api_v2.put_path(
      base_path,
      publishing_app: "content-publisher",
      override_existing: true,
    )
  end

  def publish
    GdsApi.publishing_api_v2.publish(
      live_edition.document.content_id,
      nil, # Sending update_type is deprecated (now in payload)
      locale: live_edition.document.locale,
    )
  end

  def withdraw
    GdsApi.publishing_api_v2.unpublish(
      live_edition.document.content_id,
      type: "withdrawal",
      explanation: GovspeakDocument.new(live_edition.status.details, live_edition).payload_html,
      locale: live_edition.locale,
    )
  end

  def redirect_or_remove
    removal = live_edition.status.details
    GdsApi.publishing_api_v2.unpublish(
      live_edition.content_id,
      type: removal.redirect? ? "redirect" : "gone",
      explanation: removal.explanatory_note,
      alternative_path: removal.alternative_path,
      locale: live_edition.locale,
    )
  end
end
