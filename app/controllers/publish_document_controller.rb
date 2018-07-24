# frozen_string_literal: true

class PublishDocumentController < ApplicationController
  def publish
    document = Document.find(params[:id])
    DocumentPublishingService.new.publish_live(document)
    redirect_to document, notice: "Publish successful"
  end
end
