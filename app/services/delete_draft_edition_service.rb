# frozen_string_literal: true

class DeleteDraftEditionService < ApplicationService
  def initialize(edition, user)
    @edition = edition
    @user = user
  end

  def call
    raise "Only current editions can be deleted" unless edition.current?
    raise "Trying to delete a live edition" if edition.live?

    begin
      delete_assets(edition.assets)
      discard_draft(edition)
    rescue GdsApi::BaseError
      edition.update!(revision_synced: false)
      raise
    end

    reset_live_edition if document.live_edition
    discard_path_reservations(edition) if edition.first?
    document.reload_current_edition
  end

private

  attr_reader :edition, :user
  delegate :document, to: :edition

  def discard_path_reservations(edition)
    paths = edition.revisions.map(&:base_path).uniq.compact
    publishing_app = PreviewDraftEditionService::Payload::PUBLISHING_APP

    paths.each do |path|
      GdsApi.publishing_api.unreserve_path(path, publishing_app)
    rescue GdsApi::HTTPNotFound
      Rails.logger.warn("Tried to discard unreserved path #{path}")
    end
  end

  def reset_live_edition
    document.live_edition.update!(current: true)
    document.reload_live_edition
  end

  def discard_draft(edition)
    begin
      GdsApi.publishing_api.discard_draft(edition.content_id)
    rescue GdsApi::HTTPNotFound
      Rails.logger.warn("No draft to discard for content id #{edition.content_id}")
    rescue GdsApi::HTTPUnprocessableEntity => e
      no_draft_message = "There is not a draft edition of this document to discard"

      if e.error_details.respond_to?(:dig) && e.error_details.dig("error", "message") == no_draft_message
        Rails.logger.warn("No draft to discard for content id #{edition.content_id}")
      else
        raise
      end
    end

    AssignEditionStatusService.call(edition, user: user, state: :discarded)
    edition.update!(current: false)
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
