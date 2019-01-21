# frozen_string_literal: true

class UnpublishService
  def withdraw(edition, explanatory_note)
    Document.transaction do
      edition.document.lock!
      check_unpublishable(edition)

      GdsApi.publishing_api_v2.unpublish(
        edition.content_id,
        type: "withdrawal",
        explanation: explanatory_note,
        locale: edition.locale,
      )

      withdrawal = Withdrawal.new(explanatory_note: explanatory_note)

      edition.assign_status(:retired, nil, status_details: withdrawal)
      edition.save!

      TimelineEntry.create_for_status_change(
        entry_type: :retired,
        status: edition.status,
        details: withdrawal,
      )
    end
  end

  def remove(edition, explanatory_note: nil, alternative_path: nil)
    Document.transaction do
      edition.document.lock!
      check_unpublishable(edition)

      GdsApi.publishing_api_v2.unpublish(
        edition.content_id,
        type: "gone",
        explanation: explanatory_note,
        alternative_path: alternative_path,
        locale: edition.locale,
      )

      removal = Removal.new(explanatory_note: explanatory_note,
                            alternative_path: alternative_path)

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

  def remove_and_redirect(edition, redirect_path, explanatory_note: nil)
    Document.transaction do
      edition.document.lock!
      check_unpublishable(edition)

      GdsApi.publishing_api_v2.unpublish(
        edition.content_id,
        type: "redirect",
        explanation: explanatory_note,
        alternative_path: redirect_path,
        locale: edition.locale,
      )

      removal = Removal.new(explanatory_note: explanatory_note,
                            alternative_path: redirect_path,
                            redirect: true)

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

  def check_unpublishable(edition)
    document = edition.document

    if edition != document.live_edition
      raise "attempted to unpublish an edition other than the live edition"
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
