# frozen_string_literal: true

class DraftAssetCleanupService
  def call(edition)
    current_revision = edition.revision
    previous_revision = current_revision.preceded_by

    return unless previous_revision

    delete_assets(previous_assets(previous_revision) - current_assets(current_revision))
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

  def current_assets(current_revision)
    current_image_assets = current_revision.image_revisions.flat_map(&:assets)
    current_file_attachment_assets = current_revision.file_attachment_revisions.flat_map(&:assets)
    current_image_assets + current_file_attachment_assets
  end

  def previous_assets(previous_revision)
    previous_image_assets = previous_revision.image_revisions.flat_map(&:assets)
    previous_file_attachment_assets = previous_revision.file_attachment_revisions.flat_map(&:assets)
    previous_image_assets + previous_file_attachment_assets
  end
end
