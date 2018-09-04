# frozen_string_literal: true

class PublishDocumentController < ApplicationController
  def confirmation
    @document = Document.find_by_param(params[:id])
  end

  def publish
    document = Document.find_by_param(params[:id])
    redirect_to document, notice: t("documents.show.flashes.publish_success")
    review_state = params[:self_declared_review_state] == "has-been-reviewed" ? "reviewed" : "force_published"
    DocumentPublishingService.new.publish(document, review_state)
  rescue GdsApi::BaseError => e
    document.update!(publication_state: "error_sending_to_live")
    Rails.logger.error(e)
    redirect_to document, alert: t("documents.show.flashes.publish_error")
  end

  def published
    @document = Document.find_by_param(params[:id])
end
