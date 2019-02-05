# frozen_string_literal: true

class DraftAssetCleanupService
  def call(edition)
    current_revision = edition.revision
    previous_revision = current_revision.preceded_by

    return unless previous_revision

    current_assets = current_revision.image_revisions.flat_map(&:assets)
    previous_assets = previous_revision.image_revisions.flat_map(&:assets)

    delete_assets(previous_assets - current_assets)
  end

private

  def delete_assets(assets)
    assets.each do |asset|
      next unless asset.draft?

      begin
        AssetManagerService.new.delete(asset)
      rescue GdsApi::HTTPNotFound
        Rails.logger.warn("No asset to delete for id #{asset.asset_manager_id}")
      end

      asset.absent!
    end
  end
end
