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
      upload_asset(file_attachment_revision.asset)
    end
  end

  def upload_asset(asset)
    if asset.absent?
      file_url = AssetManagerService.new.upload(asset, auth_bypass_id)
      asset.update!(file_url: file_url, state: :draft)
    elsif asset.draft?
      GdsApi.asset_manager.update_asset(asset.asset_manager_id, draft: true)
    end
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    raise
  end

private

  def auth_bypass_id
    PreviewAuthBypassService.new(edition).auth_bypass_id
  end
end
