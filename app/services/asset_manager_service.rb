# frozen_string_literal: true

require "gds_api/asset_manager"

class AssetManagerService
  def upload(file)
    upload = asset_manager.create_asset(file: file, draft: true)
    upload["file_url"]
  end

  def publish(asset)
    id = asset_id(asset.url)
    asset_manager.update_asset(id, file: asset, draft: false)
  end

private

  def asset_manager
    @asset_manager ||= GdsApi::AssetManager.new(Plek.new.find("asset-manager"))
  end

  def asset_id(file_url)
    url_array = file_url.split("/")
    # the second to last element of the array contains the asset_id
    url_array[url_array.length - 2]
  end
end
