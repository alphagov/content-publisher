# frozen_string_literal: true

class DeleteDraftService
  attr_reader :document, :user

  def initialize(document, user)
    @document = document
    @user = user
  end

  def delete
    edition = document.current_edition

    raise "Trying to delete a document without a current edition" unless edition
    raise "Trying to delete a live document" if edition.live?

    begin
      assets = edition.image_revisions.flat_map(&:assets) +
        edition.file_attachment_revisions.flat_map(&:assets)

      delete_assets(assets)
      discard_draft(edition)
    rescue GdsApi::BaseError
      document.current_edition.update!(revision_synced: false)
      raise
    end

    reset_live_edition if document.live_edition
    discard_path_reservations(edition) if edition.number == 1
  end

private

  def discard_path_reservations(edition)
    paths = edition.revisions.map(&:base_path).uniq.compact
    publishing_app = PublishingApiPayload::PUBLISHING_APP

    paths.each do |path|
      GdsApi.publishing_api.unreserve_path(path, publishing_app)
    rescue GdsApi::HTTPNotFound
      Rails.logger.warn("Tried to discard unreserved path #{path}")
    end
  end

  def reset_live_edition
    document.live_edition.update!(current: true)
  end

  def discard_draft(edition)
    begin
      GdsApi.publishing_api_v2.discard_draft(document.content_id)
    rescue GdsApi::HTTPNotFound
      Rails.logger.warn("No draft to discard for content id #{document.content_id}")
    end

    edition.assign_status(:discarded, user).update!(current: false)
  end

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
end
