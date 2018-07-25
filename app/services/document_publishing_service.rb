# frozen_string_literal: true

require 'gds_api/publishing_api_v2'

class DocumentPublishingService
  def publish_draft(document)
    publishing_api.put_content(document.content_id, payload(document))
  end

  def publish(document)
    publishing_api.publish(document.content_id, "major")
  end

private

  def payload(document)
    {
      base_path: document.base_path,
      title: document.title,
      schema_name: "news_article",
      document_type: document.document_type,
      publishing_app: "content-publisher",
      rendering_app: "government-frontend",
      details: document.contents.merge(first_public_at: Time.now.iso8601,
                                       government: {
                                         title: "Hey", slug: "what", current: true,
                                       },
                                       political: false),
      routes: [
        { path: document.base_path, type: "exact" },
      ]
    }
  end

  def publishing_api
    GdsApi::PublishingApiV2.new(
      Plek.new.find('publishing-api'),
      disable_cache: true,
      bearer_token: ENV['PUBLISHING_API_BEARER_TOKEN'] || 'example',
    )
  end
end
