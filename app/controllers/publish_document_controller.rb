# frozen_string_literal: true

class PublishDocumentController < ApplicationController
  def publish
    document = Document.find(params[:id])
    Services.publishing_api.publish(document.content_id, "major")
    redirect_to document, notice: "Publish successful"
  end
end
