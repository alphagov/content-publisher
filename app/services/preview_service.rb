# frozen_string_literal: true

class PreviewService < ApplicationService
  def initialize(edition, optional_params = {})
    @edition = edition
    @optional_params = optional_params
  end

  def call
    put_draft_assets
    put_draft_content
  rescue GdsApi::BaseError
    edition.update!(revision_synced: false)
    raise
  end

private

  attr_reader :edition, :optional_params

  def put_draft_content
    payload = Payload.new(edition).payload
    GdsApi.publishing_api_v2.put_content(edition.content_id,
                                         payload.merge(optional_params))
    edition.update!(revision_synced: true)
  end

  def put_draft_assets
    edition.image_revisions.each(&:ensure_assets)
    edition.assets.each { |asset| PreviewAssetService.call(edition, asset) }
  end
end
