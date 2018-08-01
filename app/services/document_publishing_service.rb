# frozen_string_literal: true

require 'gds_api/publishing_api_v2'

class DocumentPublishingService
  PUBLISHING_APP = "content-publisher"

  def generate_base_path(title)
    '/news/' + title.parameterize
  end

  def reserve_path(base_path)
    publishing_api.put_path(base_path, publishing_app: PUBLISHING_APP)
  end

  def publish_draft(document)
    publishing_api_v2.put_content(document.content_id, PublishingApiPayload.new(document).payload)
  end

  def publish(document)
    publishing_api_v2.publish(document.content_id, "major", locale: document.locale)
  end

private

  def publishing_api
    GdsApi::PublishingApi.new(
      Plek.new.find('publishing-api'),
      disable_cache: true,
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example',
    )
  end

  def publishing_api_v2
    GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      disable_cache: true,
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example',
    )
  end
end
