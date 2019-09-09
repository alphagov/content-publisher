# frozen_string_literal: true

class DeleteDraftService < ApplicationService
  def initialize(document, user)
    @document = document
    @user = user
  end

  def call
    edition = document.current_edition

    raise "Trying to delete a document without a current edition" unless edition
    raise "Trying to delete a live document" if edition.live?

    begin
      delete_assets(edition.assets)
      discard_draft(edition)
    rescue GdsApi::BaseError
      document.current_edition.update!(revision_synced: false)
      raise
    end

    reset_live_edition if document.live_edition
    discard_path_reservations(edition) if edition.first?
  end

private

  attr_reader :document, :user

  def discard_path_reservations(edition)
    paths = edition.revisions.map(&:base_path).uniq.compact
    publishing_app = PreviewService::Payload::PUBLISHING_APP

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
    rescue GdsApi::HTTPUnprocessableEntity => e
      no_draft_message = "There is not a draft edition of this document to discard"

      if e.error_details.respond_to?(:dig) && e.error_details.dig("error", "message") == no_draft_message
        Rails.logger.warn("No draft to discard for content id #{document.content_id}")
      else
        raise
      end
    end

    edition.assign_status(:discarded, user).update!(current: false)
  end

  def delete_assets(assets)
    assets.each do |asset|
      next unless asset.draft?

      begin
        GdsApi.asset_manager.delete_asset(asset.asset_manager_id)
      rescue GdsApi::HTTPNotFound
        Rails.logger.warn("No asset to delete for id #{asset.asset_manager_id}")
      end
      asset.absent!
    end
  end
end
