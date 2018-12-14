# frozen_string_literal: true

class PublishService
  attr_reader :document

  def initialize(document)
    @document = document
  end

  def publish(user:, review_state:)
    publish_assets(document.images)

    GdsApi.publishing_api_v2.publish(
      document.content_id,
      nil, # Sending update_type is deprecated (now in payload)
      locale: document.locale,
    )

    Document.transaction do
      document.update!(
        publication_state: "sent_to_live",
        has_live_version_on_govuk: true,
        review_state: review_state,
        live_state: "published",
      )

      TimelineEntry.create!(
        document: document,
        user: user,
        entry_type: timeline_entry_type(review_state),
      )
    end
  rescue GdsApi::BaseError => e
    GovukError.notify(e)
    document.update!(publication_state: "error_sending_to_live")
    raise
  end

private

  def timeline_entry_type(review_state)
    review_state == "reviewed" ? "published" : "published_without_review"
  end

  def publish_assets(assets)
    assets.each do |asset|
      AssetManagerService.new.publish(asset)
      asset.update!(publication_state: "live")
    end
  end
end
