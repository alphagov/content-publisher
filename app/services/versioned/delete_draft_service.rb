# frozen_string_literal: true

module Versioned
  class DeleteDraftService
    attr_reader :document, :user

    def initialize(document, user)
      @document = document
      @user = user
    end

    def delete
      raise "Trying to delete a document without a current edition" unless document.current_edition
      raise "Trying to delete a live document" if document.current_edition.live

      current_edition = document.current_edition
      current_edition.image_revisions.each { |ir| delete_image_revision(ir) }
      discard_draft

      current_edition.assign_status(:discarded, user)
                     .update!(current: false)

      live_edition = document.live_edition
      live_edition&.update!(current: true)
    rescue GdsApi::BaseError
      document.current_edition.update!(revision_synced: false)
      raise
    end

  private

    def discard_draft
      GdsApi.publishing_api_v2.discard_draft(document.content_id)
    rescue GdsApi::HTTPNotFound
      Rails.logger.warn("No draft to discard for content id #{document.content_id}")
    end

    def delete_image_revision(image_revision)
      image_revision.assets.each do |asset|
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
end
