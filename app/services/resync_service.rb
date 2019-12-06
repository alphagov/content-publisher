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
    publish
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
end
