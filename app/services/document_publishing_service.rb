# frozen_string_literal: true

require 'gds_api/publishing_api_v2'

class DocumentPublishingService
  PUBLISHING_APP = "content-publisher"

  def generate_base_path(document, proposed_title)
    document.document_type_schema.prefix + '/' + proposed_title.parameterize
  end

  def path_exists?(base_path)
    publishing_api.lookup_content_id(base_path: base_path)
  end

  def publish_draft(document)
    publishing_api.put_content(document.content_id, PublishingApiPayload.new(document).payload)
  end

  def publish(document)
    publishing_api.publish(document.content_id, "major", locale: document.locale)
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
