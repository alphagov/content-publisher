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
    sync_live_edition if live_edition
    sync_draft_edition if current_edition != live_edition
  end

private

  def sync_live_edition
    set_political_and_government(live_edition)
    PreviewService.call(live_edition, republish: true)
    PublishAssetService.call(live_edition, nil)

    if live_edition.withdrawn?
      withdraw
    elsif live_edition.removed?
      redirect_or_remove
    else
      publish
    end

    live_edition.update!(revision_synced: true)
  end

  def sync_draft_edition
    set_political_and_government(current_edition)
    PreviewService.call(current_edition)
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

  def government_id(edition)
    government = if edition.public_first_published_at
                   Government.for_date(edition.public_first_published_at)
                 else
                   Government.current
                 end
    government.content_id
  end
end
