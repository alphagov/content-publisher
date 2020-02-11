# frozen_string_literal: true

class RemoveDocumentService < ApplicationService
  def initialize(edition, removal, user: nil)
    @edition = edition
    @removal = removal
    @user = user
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

  attr_reader :edition, :removal, :user

  def unpublish_edition
    GdsApi.publishing_api.unpublish(
      edition.content_id,
      type: removal.redirect? ? "redirect" : "gone",
      explanation: removal.explanatory_note,
      alternative_path: removal.alternative_url,
      locale: edition.locale,
    )
  end

  def update_edition_status
    AssignEditionStatusService.call(edition,
                                    state: :removed,
                                    status_details: removal,
                                    user: user)
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
    unless edition.live?
      raise "attempted to remove an edition other than the live edition"
    end

    unless edition.current?
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
