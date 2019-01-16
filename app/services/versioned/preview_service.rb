# frozen_string_literal: true

module Versioned
  class PreviewService
    attr_reader :edition

    def initialize(edition)
      @edition = edition
    end

    def create_preview
      upload_assets(edition)
      publish_draft(edition)
    end

    def try_create_preview
      if has_issues?
        edition.draft_requirements_not_met!
      else
        begin
          upload_assets(edition)
          publish_draft(edition)
        rescue GdsApi::BaseError => e
          edition.draft_failure!
          GovukError.notify(e)
        end
      end
    end

  private

    def has_issues?
      Versioned::Requirements::EditionChecker.new(edition).pre_preview_issues.any?
    end

    def publish_draft(edition)
      payload = Versioned::PublishingApiPayload.new(edition).payload
      GdsApi.publishing_api_v2.put_content(edition.content_id, payload)
      edition.draft_available!
    rescue GdsApi::BaseError
      edition.draft_failure!
      raise
    end

    def upload_assets(edition)
      edition.image_revisions.each do |image_revision|
        image_revision.ensure_asset_manager_variants

        image_revision.asset_manager_variants.each do |variant|
          upload_image(edition, variant)
        end
      end
    rescue GdsApi::BaseError
      edition.draft_failure!
      raise
    end

    def upload_image(edition, asset_manager_variant)
      return unless asset_manager_variant.absent?

      auth_bypass_id = Versioned::EditionUrl.new(edition).auth_bypass_id
      file_url = Versioned::AssetManagerService.new
                                               .upload(asset_manager_variant, auth_bypass_id)
      asset_manager_variant.file.update!(file_url: file_url, state: :draft)
    end
  end
end
