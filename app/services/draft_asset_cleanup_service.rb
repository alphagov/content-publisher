# frozen_string_literal: true

class DraftAssetCleanupService
  def call(edition)
    current_revision = edition.revision
    previous_revision = current_revision.preceded_by

    return unless previous_revision

    delete_assets(previous_revision.assets - current_revision.assets)
  end

private

  def delete_assets(assets)
    assets.each do |asset|
      next unless asset.draft?

      begin
        GdsApi.asset_manager.delete_asset(asset.asset_manager_id)
      rescue GdsApi::HTTPNotFound
        Rails.logger.warn("No asset to delete for id #{asset.asset_manager_id}")
      end

      asset.absent!
    end
  end
end
