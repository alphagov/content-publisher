# frozen_string_literal: true

require 'gds_api/publishing_api_v2'

class DocumentPublishingService
  def publish_draft(document)
    document.update!(publication_state: "sending_to_draft")
    publishing_api.put_content(document.content_id, PublishingApiPayload.new(document).payload)
    document.update!(publication_state: "sent_to_draft")
  end

  def publish(document)
    document.update!(publication_state: "publishing")
    publishing_api.publish(document.content_id, "major", locale: document.locale)
    document.update!(publication_state: "live_on_govuk")
  end

private

  def publishing_api
    GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      disable_cache: true,
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example',
    )
  end
end
