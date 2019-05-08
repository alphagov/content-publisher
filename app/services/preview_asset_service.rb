# frozen_string_literal: true

class PreviewAssetService
  attr_reader :edition

  def initialize(edition)
    @edition = edition
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
