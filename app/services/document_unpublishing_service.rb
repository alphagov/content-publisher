# frozen_string_literal: true

class DocumentUnpublishingService
  def retire(document, explanatory_note)
    GdsApi.publishing_api_v2.unpublish(
      document.content_id,
      type: "withdrawal",
      explanation: explanatory_note,
      locale: document.locale,
    )

    TimelineEntry.create!(document: document, entry_type: "retired")
  end

  def remove(document, explanatory_note: nil, alternative_path: nil)
    GdsApi.publishing_api_v2.unpublish(
      document.content_id,
      type: "gone",
      explanation: explanatory_note,
      alternative_path: alternative_path,
      locale: document.locale,
    )

    delete_assets(document.images)
    TimelineEntry.create!(document: document, entry_type: "removed")
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
  end

private

  def delete_assets(assets)
    assets.each do |asset|
      AssetManagerService.new.delete(asset)
    end
  end
end
