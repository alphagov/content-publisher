# frozen_string_literal: true

class ResyncService < ApplicationService
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def call
    update_live_edition(document.live_edition) if document.live_edition
    update_current_edition(document.current_edition) unless
      document.current_edition == document.live_edition
  end

private

  def update_live_edition(edition)
    edition.update!(
      revision_synced: false,
      system_political: PoliticalEditionIdentifier.new(edition).political?,
      government_id: government_id(edition, document),
    )

    PreviewService.call(
      edition,
      update_type: "republish",
      bulk_publishing: true,
    )

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

  def update_current_edition(edition)
    edition.update!(
      revision_synced: false,
      system_political: PoliticalEditionIdentifier.new(edition).political?,
    )
    PreviewService.call(edition)
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
      type: "redirect",
      explanation: removal.explanatory_note,
      alternative_path: removal.alternative_path,
      locale: edition.locale,
    )
  end

  def government_id(edition, document)
    date = edition.backdated_to || document.first_published_at
    return unless date

    Government.for_date(date)&.content_id
  end
end
