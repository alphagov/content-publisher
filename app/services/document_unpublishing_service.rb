# frozen_string_literal: true

class DocumentUnpublishingService
  def retire(document, explanatory_note)
    Document.transaction do
      document.update!(live_state: "retired")
      TimelineEntry.create!(document: document, entry_type: "retired")

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
      TimelineEntry.create!(document: document, entry_type: "removed")

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
    GdsApi.publishing_api_v2.unpublish(
      document.content_id,
      type: "redirect",
      explanation: explanatory_note,
      alternative_path: redirect_path,
      locale: document.locale,
    )

    delete_assets(document.images)
    document.update!(live_state: "removed")
    TimelineEntry.create!(document: document, entry_type: "removed")
  end

private

  def delete_assets(assets)
    assets.each do |asset|
      AssetManagerService.new.delete(asset)
    end
  end
end
