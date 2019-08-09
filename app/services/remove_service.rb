# frozen_string_literal: true

class RemoveService < ApplicationService
  def initialize(edition, removal)
    @edition = edition
    @removal = removal
  end

  def call
    Document.transaction do
      edition.document.lock!
      check_removeable
      unpublish_edition
      update_edition_status
      create_timeline_entry
    end

    delete_assets
  end

private

  attr_reader :edition, :removal

  def unpublish_edition
    GdsApi.publishing_api_v2.unpublish(
      edition.content_id,
      type: removal.redirect? ? "redirect" : "gone",
      explanation: removal.explanatory_note,
      alternative_path: removal.alternative_path,
      locale: edition.locale,
    )
  end

  def update_edition_status
    edition.assign_status(:removed, nil, status_details: removal)
    edition.save!
  end

  def create_timeline_entry
    TimelineEntry.create_for_status_change(
      entry_type: :removed,
      status: edition.status,
      details: removal,
    )
  end

  def check_removeable
    document = edition.document

    if edition != document.live_edition
      raise "attempted to remove an edition other than the live edition"
    end

    if document.current_edition != document.live_edition
      raise "Publishing API does not support unpublishing while there is a draft"
    end
  end

  def delete_assets
    edition.assets.each do |asset|
      next if asset.absent?

      begin
        GdsApi.asset_manager.delete_asset(asset.asset_manager_id)
      rescue GdsApi::HTTPNotFound
        Rails.logger.warn("No asset to delete for id #{asset.asset_manager_id}")
      end

      asset.absent!
    end
  end
end
