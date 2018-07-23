# frozen_string_literal: true

class DocumentsController < ApplicationController
  def index
    @documents = Document.all
  end

  def edit
    @document = Document.find(params[:id])
  end

  def show
    @document = Document.find(params[:id])
  end

  def update
    document = Document.find(params[:id])
    allowed_field_names_in_contents = document.document_type_schema.fields.map(&:id)
    document_update_params = params.require(:document).permit(:title, contents: allowed_field_names_in_contents)
    document.update_attributes(document_update_params)
    Services.publishing_api.put_content(document.content_id, payload(document))
    redirect_to edit_document_path(document)
  end

private

  def document_update_params
    params.require(:document).permit(:title)
  end

  def payload(document)
    {
      base_path: "/test/government/foo",
      title: document.title,
      schema_name: "news_article",
      document_type: document.document_type,
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
