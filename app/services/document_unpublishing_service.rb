# frozen_string_literal: true

class DocumentUnpublishingService
  def retire(document, explanatory_note)
    GdsApi.publishing_api_v2.unpublish(document.content_id, type: "withdrawal", explanation: explanatory_note)
  end

  def remove(document, redirect_path: nil)
    delete_assets(document.images)

    return GdsApi.publishing_api_v2.unpublish(document.content_id, type: "redirect", alternative_path: redirect_path) if redirect_path.present?
    GdsApi.publishing_api_v2.unpublish(document.content_id, type: "gone")
  end

private

  def delete_assets(assets)
    assets.each do |asset|
      AssetManagerService.new.delete(asset)
    end
  end
end
