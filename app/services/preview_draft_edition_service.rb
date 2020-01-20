# frozen_string_literal: true

class PreviewDraftEditionService < ApplicationService
  def initialize(edition, republish: false)
    @edition = edition
    @republish = republish
  end

  def call
    put_draft_assets
    put_draft_content
  rescue GdsApi::BaseError
    edition.update!(revision_synced: false)
    raise
  end

private

  attr_reader :edition, :republish

  def put_draft_content
    payload = Payload.new(edition, republish: republish).payload
    GdsApi.publishing_api.put_content(edition.content_id, payload)
    edition.update!(revision_synced: true)
  end

  def put_draft_assets
    edition.image_revisions.each(&:ensure_assets)
    edition.assets.each { |asset| PreviewAssetService.call(edition, asset) }
  end
end
