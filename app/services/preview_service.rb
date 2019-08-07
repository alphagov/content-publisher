# frozen_string_literal: true

class PreviewService
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def create_preview
    put_draft_assets
    put_draft_content
    cleanup_draft_assets
  rescue GdsApi::BaseError
    edition.update!(revision_synced: false)
    raise
  end

private

  def put_draft_content
    payload = Payload.new(edition).payload
    GdsApi.publishing_api_v2.put_content(edition.content_id, payload)
    edition.update!(revision_synced: true)
  end

  def put_draft_assets
    edition.image_revisions.each(&:ensure_assets)
    service = PreviewAssetService.new(edition)
    edition.assets.each { |asset| service.put(asset) }
  end

  def cleanup_draft_assets
    DraftAssetCleanupService.new.call(edition)
  end
end
