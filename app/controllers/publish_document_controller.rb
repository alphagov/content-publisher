# frozen_string_literal: true

class PublishDocumentController < ApplicationController
  def publish
    @document = Document.find(params[:id])
    Services.publishing_api.put_content(@document.content_id, payload)
    Services.publishing_api.publish(@document.content_id, "major")
    redirect_to @document, notice: "Publish successful"
  end

  private

  def payload
    {
      base_path: "/test/government/foo",
      title: @document.title,
      schema_name: "news_article",
      document_type: @document.document_type,
      publishing_app: "content-publisher",
      rendering_app: "government-frontend",
      details: {
        body: "Hello!",
        first_public_at: Time.now.iso8601,
        government: {
          title: "Hey", slug: "what", current: true,
        },
        political: false,
      },
      routes: [
        { path: "/test/government/foo", type: "exact" }
      ]
    }
  end
end
