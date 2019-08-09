# frozen_string_literal: true

class PreviewService < ApplicationService
  def initialize(edition)
    @edition = edition
  end

  def call
    put_draft_assets
    put_draft_content
    cleanup_draft_assets
  rescue GdsApi::BaseError
    edition.update!(revision_synced: false)
    raise
  end

private

  attr_reader :edition

  def put_draft_content
    payload = Payload.new(edition).payload
    GdsApi.publishing_api_v2.put_content(edition.content_id, payload)
    edition.update!(revision_synced: true)
  end

  def put_draft_assets
    edition.image_revisions.each(&:ensure_assets)
    edition.assets.each { |asset| PreviewAssetService.call(edition, asset) }
  end

  def cleanup_draft_assets
    DraftAssetCleanupService.call(edition)
  end
end
