# frozen_string_literal: true

class AssetCleanupJob < ApplicationJob
  def perform
    clean_image_assets
    clean_file_attachment_assets
  end

private

  def clean_image_assets
    image_asset_used =
      Edition.where(current: true)
             .or(Edition.where(live: true))
             .joins(revision: { image_revisions: :blob_revision })
             .where("image_assets.blob_revision_id = image_blob_revisions.id")
             .arel
             .exists

    Image::Asset.where.not(state: :absent)
                .where.not(image_asset_used)
                .find_each { |asset| delete_asset(asset) }
  end

  def clean_file_attachment_assets
    file_attachment_asset_used =
      Edition.where(current: true)
             .or(Edition.where(live: true))
             .joins(revision: { file_attachment_revisions: :blob_revision })
             .where("file_attachment_assets.blob_revision_id = file_attachment_blob_revisions.id")
             .arel
             .exists

    FileAttachment::Asset.where.not(state: :absent)
                         .where.not(file_attachment_asset_used)
                         .find_each { |asset| delete_asset(asset) }
  end

  def delete_asset(asset)
    GdsApi.asset_manager.delete_asset(asset.asset_manager_id)
  rescue GdsApi::HTTPNotFound
    Rails.logger.warn("No asset to delete for id #{asset.asset_manager_id}")
  ensure
    asset.absent!
  end
end
