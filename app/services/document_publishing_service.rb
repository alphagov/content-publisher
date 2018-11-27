# frozen_string_literal: true

class DocumentPublishingService
  def publish(document, review_state)
    document.update!(publication_state: "sending_to_live", review_state: review_state)
    publish_assets(document.images)

    # Sending update_type in .publish is deprecated (should be in payload instead)
    GdsApi.publishing_api_v2.publish(document.content_id, nil, locale: document.locale)
    document.update!(publication_state: "sent_to_live", has_live_version_on_govuk: true)
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    document.update!(publication_state: "error_sending_to_live")
    raise
  end

private

  def publish_assets(assets)
    asset_manager = AssetManagerService.new
    assets.each { |asset| asset_manager.publish(asset) }
  end
end
