# frozen_string_literal: true

class PreviewService
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def create_preview
    PreviewAssetService.new(edition).put_all
    publish_draft
    DraftAssetCleanupService.new.call(edition)
  rescue GdsApi::BaseError
    edition.update!(revision_synced: false)
    raise
  end

private

  def publish_draft
    payload = Payload.new(edition).payload
    GdsApi.publishing_api_v2.put_content(edition.content_id, payload)
    edition.update!(revision_synced: true)
  end
end
