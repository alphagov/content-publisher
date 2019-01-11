# frozen_string_literal: true

module Versioned
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
      current_edition.draft = :not_applicable
      current_edition.save!
    end

    def set_first_published_at
      return if document.first_published_at

      document.update!(first_published_at: Time.zone.now)
    end

    def publish_new_images
      return unless current_edition.lead_image_revision

      # we currently only use the lead image
      current_edition.lead_image_revision.asset_manager_variants.each do |variant|
        raise "Expected variant to be on asset manager" if variant.absent?

        if variant.draft?
          Versioned::AssetManagerService.new.publish(variant)
          variant.file.live!
        end
      end
    end

    def retire_old_images
      return unless live_edition

      live_edition.image_revisions.each do |revision|
        next if revision == current_edition.lead_image_revision

        if revision.image_id == current_edition.lead_image_revision&.image_id
          redirect_images(revision, current_edition.lead_image_revision)
        else
          revision.asset_manager_variants.each { |v| remove_image_variant(v) }
        end
      end
    end

    def remove_image_variant(variant)
      return if variant.absent?

      begin
        Versioned::AssetManagerService.new.delete(variant)
      rescue GdsApi::HTTPNotFound
        Rails.logger.warn("No asset to delete for id #{variant.asset_manager_id}")
      end

      variant.file.absent!
    end

    def redirect_images(old_revision, new_revision)
      grouped_old = old_revision.asset_manager_variants.group_by(&:variant)
      grouped_new = new_revision.asset_manager_variants.group_by(&:variant)
      to_remove = grouped_old.keys - grouped_new.keys

      to_remove.each { |variant| remove_image_variant(grouped_old[variant].first) }

      to_supersede = grouped_new.keys & grouped_old.keys
      to_supersede.each do |variant_name|
        old_variant = grouped_old[variant_name].first
        new_variant = grouped_new[variant_name].first

        next if old_variant.absent?

        begin
          Versioned::AssetManagerService.new.redirect(old_variant, to: new_variant.file_url)
          old_variant.file.update!(state: :superseded, superseded_by: new_variant.file)
        rescue GdsApi::HTTPNotFound
          Rails.logger.warn("No asset to supersede for id #{variant.asset_manager_id}")
          old_variant.file.absent!
        end
      end
    end
  end
end
