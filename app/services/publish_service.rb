# frozen_string_literal: true

class PublishService
  attr_reader :document
  delegate :current_edition, :live_edition, to: :document

  def initialize(document)
    @document = document
  end

  def publish(user:, with_review:)
    publish_new_images
    retire_old_images

    GdsApi.publishing_api_v2.publish(
      document.content_id,
      nil, # Sending update_type is deprecated (now in payload)
      locale: document.locale,
    )

    supersede_live_edition(user)
    set_new_live_edition(user, with_review)
    set_first_published_at

    current_edition
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    raise
  end

private

  def supersede_live_edition(user)
    return unless live_edition

    live_edition.assign_status(:superseded, user, update_last_edited: false)
    live_edition.live = false
    live_edition.save!
  end

  def set_new_live_edition(user, with_review)
    status = with_review ? :published : :published_but_needs_2i
    current_edition.assign_status(status, user)
    current_edition.live = true
    current_edition.save!
  end

  def set_first_published_at
    return if document.first_published_at

    document.update!(first_published_at: Time.current)
  end

  def publish_new_images
    return unless current_edition.image_revisions.any?

    current_edition.image_revisions.each do |image_revision|
      image_revision.assets.each do |asset|
        raise "Expected asset to be on asset manager" if asset.absent?

        if asset.draft?
          AssetManagerService.new.publish(asset)
          asset.live!
        end
      end
    end
  end

  def retire_old_images
    return unless live_edition

    image_revisions = current_edition.image_revisions
    current_file_revisions = image_revisions.map(&:file_revision)
    current_revisions_by_image_id = image_revisions.group_by(&:image_id)

    live_edition.image_revisions.each do |revision|
      next if current_file_revisions.include?(revision.file_revision)

      if current_revisions_by_image_id.has_key?(revision.image_id)
        redirect_images(
          revision,
          current_revisions_by_image_id[revision.image_id].first,
        )
      else
        revision.assets.each { |a| remove_image_asset(a) }
      end
    end
  end

  def redirect_images(old_revision, new_revision)
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

    begin
      AssetManagerService.new.redirect(from_asset, to: to_asset.file_url)
      from_asset.update!(state: :superseded, superseded_by: to_asset)
    rescue GdsApi::HTTPNotFound
      Rails.logger.warn("No asset to supersede for id #{from_asset.asset_manager_id}")
      from_asset.absent!
    end
  end
end
