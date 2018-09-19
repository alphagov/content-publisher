# frozen_string_literal: true

require "gds_api/publishing_api_v2"

class DocumentPublishingService
  def publish_draft(document)
    document.update!(publication_state: "sending_to_draft")
    publishing_api.put_content(document.content_id, PublishingApiPayload.new(document).payload)
    document.update!(publication_state: "sent_to_draft")
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    document.update!(publication_state: "error_sending_to_draft")
    raise
  end

  def publish(document, review_state)
    document.update!(publication_state: "sending_to_live", review_state: review_state)
    publish_assets(document.images)
    publishing_api.publish(document.content_id, nil, locale: document.locale)
    document.update!(publication_state: "sent_to_live", change_note: nil, update_type: "major", has_live_version_on_govuk: true)
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    document.update!(publication_state: "error_sending_to_live")
    raise
  end

  def discard_draft(document)
    delete_assets(document.images)
    publishing_api.discard_draft(document.content_id)
    document.update!(publication_state: "changes_not_sent_to_draft")
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    document.update!(publication_state: "error_deleting_draft")
    raise
  end

private

  def publishing_api
    GdsApi::PublishingApiV2.new(
      Plek.new.find("publishing-api"),
      disable_cache: true,
      bearer_token: ENV["PUBLISHING_API_BEARER_TOKEN"] || "example",
    )
  end

  def publish_assets(assets)
    asset_manager = AssetManagerService.new
    assets.each { |asset| asset_manager.publish(asset) }
  end

  def delete_assets(assets)
    asset_manager = AssetManagerService.new
    assets.each { |asset| asset_manager.delete(asset) }
  end
end
