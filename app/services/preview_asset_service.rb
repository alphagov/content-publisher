# frozen_string_literal: true

class PreviewAssetService
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def upload_assets
    edition.image_revisions.each do |image_revision|
      image_revision.ensure_assets
      image_revision.assets.each { |asset| upload_asset(asset) }
    end

    edition.file_attachment_revisions.each do |file_attachment_revision|
      file_attachment_revision.ensure_assets
      file_attachment_revision.assets.each { |asset| upload_asset(asset) }
    end
  end

  def upload_asset(asset)
    return unless asset.absent?

    auth_bypass_id = EditionUrl.new(edition).auth_bypass_id
    file_url = AssetManagerService.new.upload(asset, auth_bypass_id)
    asset.update!(file_url: file_url, state: :draft)
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    raise
  end

  def can_preview_asset?(asset)
    AssetManagerService.new.get(asset)["state"] == "uploaded"
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    raise
  end
end
