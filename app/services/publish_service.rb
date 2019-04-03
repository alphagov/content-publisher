# frozen_string_literal: true

class PublishService
  attr_reader :edition
  delegate :document, to: :edition

  def initialize(edition)
    @edition = edition
  end

  def publish(user:, with_review:)
    live_edition = document.live_edition

    publish_new_images
    retire_old_images(live_edition)

    GdsApi.publishing_api_v2.publish(
      document.content_id,
      nil, # Sending update_type is deprecated (now in payload)
      locale: document.locale,
    )

    supersede_live_edition(live_edition, user)
    set_new_live_edition(user, with_review)
    set_first_published_at

    document.reload
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    raise
  end

private

  def supersede_live_edition(live_edition, user)
    return unless live_edition

    live_edition.assign_status(:superseded, user, update_last_edited: false)
    live_edition.live = false
    live_edition.save!
  end

  def set_new_live_edition(user, with_review)
    status = with_review ? :published : :published_but_needs_2i
    edition.assign_status(status, user)
    edition.live = true
    edition.save!
  end

  def set_first_published_at
    return if document.first_published_at

    document.update!(first_published_at: Time.current)
  end

  def publish_new_images
    assets = edition.image_revisions.flat_map(&:assets)

    assets.each do |asset|
      raise "Expected asset to be on asset manager" if asset.absent?
      next unless asset.draft?

      AssetManagerService.new.publish(asset)
      asset.live!
    end
  end

  def retire_old_images(live_edition)
    return unless live_edition

    live_edition.image_revisions.each do |old_revision|
      new_revision = find_image_revision(edition, old_revision)

      if new_revision
        redirect_image_assets(old_revision, new_revision)
      else
        old_revision.assets.each { |a| remove_image_asset(a) }
      end
    end
  end

  def redirect_image_assets(old_revision, new_revision)
    old_revision.assets.each do |old_asset|
      new_asset = new_revision.asset(old_asset.variant)

      if new_asset
        redirect_image_asset(old_asset, new_asset)
      else
        remove_image_asset(old_asset)
      end
    end
  end

  def remove_image_asset(asset)
    return if asset.absent?

    begin
      AssetManagerService.new.delete(asset)
    rescue GdsApi::HTTPNotFound
      Rails.logger.warn("No asset to delete for id #{asset.asset_manager_id}")
    end

    asset.absent!
  end

  def redirect_image_asset(from_asset, to_asset)
    return if from_asset.absent?
    return if from_asset == to_asset

    begin
      AssetManagerService.new.redirect(from_asset, to: to_asset.file_url)
      from_asset.update!(state: :superseded, superseded_by: to_asset)
    rescue GdsApi::HTTPNotFound
      Rails.logger.warn("No asset to supersede for id #{from_asset.asset_manager_id}")
      from_asset.absent!
    end
  end

  def find_image_revision(edition, old_revision)
    edition.image_revisions.find { |r| r.image_id == old_revision.image_id }
  end
end
