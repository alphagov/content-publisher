# frozen_string_literal: true

class AssetCleanupJob < ApplicationJob
  def perform
    active_revision_ids = Edition
      .where(current: true)
      .or(Edition.where(live: true))
      .pluck(:revision_id)

    active_file_attachment_asset_ids = FileAttachment::Revision
      .joins(:revisions, blob_revision: [:asset])
      .where("revisions.id" => active_revision_ids)
      .pluck("file_attachment_assets.id")

    active_image_asset_ids = Image::Revision
      .joins(:revisions, blob_revision: [:assets])
      .where("revisions.id" => active_revision_ids)
      .pluck("image_assets.id")

    FileAttachment::Asset
      .where.not(id: active_file_attachment_asset_ids)
      .where.not(state: "absent")
      .each { |asset| delete_asset(asset) }

    Image::Asset
      .where.not(id: active_image_asset_ids)
      .where.not(state: "absent")
      .each { |asset| delete_asset(asset) }
  end

private

  def delete_asset(asset)
    GdsApi.asset_manager.delete_asset(asset.asset_manager_id)
  rescue GdsApi::HTTPNotFound
    Rails.logger.warn("No asset to delete for id #{asset.asset_manager_id}")
  ensure
    asset.absent!
  end
end
