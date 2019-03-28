# frozen_string_literal: true

class RemoveService
  def call(edition, removal)
    Document.transaction do
      edition.document.lock!
      check_removeable(edition)

      GdsApi.publishing_api_v2.unpublish(
        edition.content_id,
        type: removal.redirect? ? "redirect" : "gone",
        explanation: removal.explanatory_note,
        alternative_path: removal.alternative_path,
        locale: edition.locale,
      )

      edition.assign_status(:removed, nil, status_details: removal)
      edition.save!

      TimelineEntry.create_for_status_change(
        entry_type: :removed,
        status: edition.status,
        details: removal,
      )
    end

    delete_assets(edition)
  end

private

  def check_removeable(edition)
    document = edition.document

    if edition != document.live_edition
      raise "attempted to remove an edition other than the live edition"
    end

    if document.current_edition != document.live_edition
      raise "Publishing API does not support unpublishing while there is a draft"
    end
  end

  def delete_assets(edition)
    edition.image_revisions.each { |ir| remove_image_revision(ir) }
  end

  def remove_image_revision(image_revision)
    image_revision.assets.each do |asset|
      next if asset.absent?

      begin
        AssetManagerService.new.delete(asset)
      rescue GdsApi::HTTPNotFound
        Rails.logger.warn("No asset to delete for id #{asset.asset_manager_id}")
      end

      asset.absent!
    end
  end
end
