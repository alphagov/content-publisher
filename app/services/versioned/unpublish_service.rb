# frozen_string_literal: true

module Versioned
  class UnpublishService
    def retire(edition, explanatory_note)
      Versioned::Document.transaction do
        edition.document.lock!

        GdsApi.publishing_api_v2.unpublish(
          edition.content_id,
          type: "withdrawal",
          explanation: explanatory_note,
          locale: edition.locale,
        )

        retirement = Versioned::Retirement.new(explanatory_note: explanatory_note)

        edition.assign_status(nil, :retired, status_details: retirement)
        edition.save!

        Versioned::TimelineEntry.create_for_status_change(
          entry_type: :retired,
          status: edition.status,
          details: retirement,
        )
      end
    end

    def remove(edition, explanatory_note: nil, alternative_path: nil)
      Versioned::Document.transaction do
        edition.document.lock!

        GdsApi.publishing_api_v2.unpublish(
          edition.content_id,
          type: "gone",
          explanation: explanatory_note,
          alternative_path: alternative_path,
          locale: edition.locale,
        )

        removal = Versioned::Removal.new(explanatory_note: explanatory_note,
                                         alternative_path: alternative_path)

        edition.assign_status(nil, :removed, status_details: removal)
        edition.save!

        Versioned::TimelineEntry.create_for_status_change(
          entry_type: :removed,
          status: edition.status,
          details: removal,
        )
      end

      delete_assets(edition)
    end

    def remove_and_redirect(edition, redirect_path, explanatory_note: nil)
      Versioned::Document.transaction do
        edition.document.lock!

        GdsApi.publishing_api_v2.unpublish(
          edition.content_id,
          type: "redirect",
          explanation: explanatory_note,
          alternative_path: redirect_path,
          locale: edition.locale,
        )

        removal = Versioned::Removal.new(explanatory_note: explanatory_note,
                                         alternative_path: redirect_path,
                                         redirect: true)

        edition.assign_status(nil, :removed, status_details: removal)
        edition.save!

        Versioned::TimelineEntry.create_for_status_change(
          entry_type: :removed,
          status: edition.status,
          details: removal,
        )
      end

      delete_assets(edition)
    end

  private

    def delete_assets(edition)
      edition.image_revisions.each do |image_revision|
        potential_draft = edition.document.current_edition

        # If this image is also used on a draft of this document we need to
        # set it as a draft rather than remove it otherwise we break the draft
        if draft_has_image_revision?(edition.document, image_revision)
          draft_image_revision(image_revision, potential_draft)
        else
          remove_image_revision(image_revision)
        end
      end
    end

    def draft_has_image_revision?(document, image_revision)
      draft = document.current_edition
      return false if !draft || draft == document.live_edition

      draft.image_revisions.include?(image_revision)
    end

    def draft_image_revision(image_revision, edition)
      image_revision.asset_manager_variants.each do |variant|
        next if variant.absent?

        begin
          auth_bypass_id = Versioned::EditionUrl.new(edition).auth_bypass_id
          Versioned::AssetManagerService.new.draft(variant, auth_bypass_id)
          variant.file.draft!
        rescue GdsApi::HTTPNotFound
          Rails.logger.warn("No asset to draft for id #{variant.asset_manager_id}")
          variant.file.absent!
        end
      end
    end

    def remove_image_revision(image_revision)
      image_revision.asset_manager_variants.each do |variant|
        next if variant.absent?

        begin
          Versioned::AssetManagerService.new.delete(variant)
        rescue GdsApi::HTTPNotFound
          Rails.logger.warn("No asset to delete for id #{variant.asset_manager_id}")
        end

        variant.file.absent!
      end
    end
  end
end
