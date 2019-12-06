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
    FailsafePreviewService.call(current_edition)
  end

  def publish
    GdsApi.publishing_api_v2.publish(
      live_edition.document.content_id,
      nil, # Sending update_type is deprecated (now in payload)
      locale: live_edition.document.locale,
    )
  end

  def withdraw
    withdrawal = live_edition.status.details
    explanation_html = GovspeakDocument.new(withdrawal.public_explanation, live_edition).payload_html

    GdsApi.publishing_api_v2.unpublish(
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
    GdsApi.publishing_api_v2.unpublish(
      live_edition.content_id,
      type: removal.redirect? ? "redirect" : "gone",
      explanation: removal.explanatory_note,
      alternative_path: removal.alternative_path,
      locale: live_edition.locale,
      unpublished_at: removal.created_at,
      allow_draft: true,
    )
  end
end
