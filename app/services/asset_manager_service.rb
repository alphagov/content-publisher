# frozen_string_literal: true

require "gds_api/asset_manager"

class AssetManagerService
  def upload(file)
    asset_manager.create_asset(file: file, draft: true)
  rescue GdsApi::BaseError => e
    false
  end

private

  def asset_manager
    GdsApi::AssetManager.new(Plek.new.find("asset-manager"))
  end
end
