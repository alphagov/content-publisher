# frozen_string_literal: true

require "gds_api/asset_manager"

class AssetManagerService
  def upload(file)
    upload = asset_manager.create_asset(file: file, draft: true)
    upload["file_url"]
  end

private

  def asset_manager
    GdsApi::AssetManager.new(Plek.new.find("asset-manager"))
  end
end
