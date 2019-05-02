# frozen_string_literal: true

class PublishAssetService
  def publish_assets(edition, live_edition)
    edition.assets.each do |asset|
      raise "Expected asset to be on asset manager" if asset.absent?
      next unless asset.draft?

      AssetManagerService.new.publish(asset)
      asset.live!
    end

    retire_old_file_attachments(edition, live_edition)
    retire_old_images(edition, live_edition)
  end

private

  def retire_old_file_attachments(edition, live_edition)
    return unless live_edition

    live_edition.file_attachment_revisions.each do |live_revision|
      current_revision = find_file_attachment_revision(edition, live_revision)

      if current_revision
        redirect_assets(live_revision, current_revision)
      else
        live_revision.assets.each { |a| delete_asset(a) }
      end
    end
  end

  def retire_old_images(edition, live_edition)
    return unless live_edition

    live_edition.image_revisions.each do |live_revision|
      current_revision = find_image_revision(edition, live_revision)

      if current_revision
        redirect_assets(live_revision, current_revision)
      else
        live_revision.assets.each { |a| delete_asset(a) }
      end
    end
  end

  def redirect_assets(live_revision, current_revision)
    live_revision.assets.each do |live_asset|
      current_asset = current_revision.asset(live_asset.variant)

      if current_asset
        redirect_asset(live_asset, current_asset)
      else
        delete_asset(live_asset)
      end
    end
  end

  def redirect_asset(live_asset, current_asset)
    return if live_asset.absent?
    return if live_asset == current_asset

    begin
      AssetManagerService.new.redirect(live_asset, to: current_asset.file_url)
      live_asset.update!(state: :superseded, superseded_by: current_asset)
    rescue GdsApi::HTTPNotFound
      Rails.logger.warn("No asset to supersede for id #{live_asset.asset_manager_id}")
      live_asset.absent!
    end
  end

  def delete_asset(live_asset)
    return if live_asset.absent?

    begin
      AssetManagerService.new.delete(live_asset)
    rescue GdsApi::HTTPNotFound
      Rails.logger.warn("No asset to delete for id #{live_asset.asset_manager_id}")
    end

    live_asset.absent!
  end

  def find_image_revision(edition, live_revision)
    edition.image_revisions.find do |r|
      r.image_id == live_revision.image_id
    end
  end

  def find_file_attachment_revision(edition, live_revision)
    edition.file_attachment_revisions.find do |r|
      r.file_attachment_id == live_revision.file_attachment_id
    end
  end
end
