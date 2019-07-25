# frozen_string_literal: true

class AssetManagerService
  def delete(asset)
    GdsApi.asset_manager.delete_asset(asset.asset_manager_id)
  end
end
