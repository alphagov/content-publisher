# frozen_string_literal: true

class UnpublishService
  def retire(document, explanatory_note)
    Document.transaction do
      document.update!(live_state: "retired")
      timeline_entry = TimelineEntry.create!(document: document, entry_type: "retired")
      Retirement.create!(timeline_entry: timeline_entry, explanatory_note: explanatory_note)

      GdsApi.publishing_api_v2.unpublish(
        document.content_id,
        type: "withdrawal",
        explanation: explanatory_note,
        locale: document.locale,
      )
    end
  end

  def remove(document, explanatory_note: nil, alternative_path: nil)
    Document.transaction do
      document.update!(live_state: "removed")
      timeline_entry = TimelineEntry.create!(document: document, entry_type: "removed")
      Removal.create!(
        timeline_entry: timeline_entry,
        explanatory_note: explanatory_note,
        alternative_path: alternative_path,
      )

      GdsApi.publishing_api_v2.unpublish(
        document.content_id,
        type: "gone",
        explanation: explanatory_note,
        alternative_path: alternative_path,
        locale: document.locale,
      )
    end

    delete_assets(document.images)
  end

  def remove_and_redirect(document, redirect_path, explanatory_note: nil)
    Document.transaction do
      document.update!(live_state: "removed")
      timeline_entry = TimelineEntry.create!(document: document, entry_type: "removed")

      Removal.create!(
        timeline_entry: timeline_entry,
        explanatory_note: explanatory_note,
        alternative_path: redirect_path,
        redirect: true,
      )

      GdsApi.publishing_api_v2.unpublish(
        document.content_id,
        type: "redirect",
        explanation: explanatory_note,
        alternative_path: redirect_path,
        locale: document.locale,
      )
    end

    delete_assets(document.images)
  end

private

  def delete_assets(assets)
    assets.each do |asset|
      AssetManagerService.new.delete(asset)
    end
  end
end
