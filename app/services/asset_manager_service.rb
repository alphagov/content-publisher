# frozen_string_literal: true

class AssetManagerService
  def publish(asset)
    GdsApi.asset_manager.update_asset(
      asset.asset_manager_id,
      draft: false,
      auth_bypass_ids: [],
      redirect_url: nil,
    )
  end

  def redirect(asset, to:)
    GdsApi.asset_manager.update_asset(
      asset.asset_manager_id,
      redirect_url: to,
    )
  end

  def delete(asset)
    GdsApi.asset_manager.delete_asset(asset.asset_manager_id)
  end
end
