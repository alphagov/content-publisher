# frozen_string_literal: true

class PublishDocumentController < ApplicationController
  def confirmation
    @document = Document.find_by_param(params[:id])
  end

  def publish
    document = Document.find_by_param(params[:id])
    review_state = params[:self_declared_review_state] == "has-been-reviewed" ? "reviewed" : "force_published"
    DocumentPublishingService.new.publish(document, review_state)
    redirect_to document_published_path(document)
  rescue GdsApi::BaseError => e
    document.update!(publication_state: "error_sending_to_live")
    Rails.logger.error(e)
    redirect_to document, alert: t("documents.show.flashes.publish_error")
  end

  def published
    @document = Document.find_by_param(params[:id])
  end
end
