# frozen_string_literal: true

class PublishDocumentController < ApplicationController
  def confirmation
    @document = Document.find(params[:id])
  end

  def publish
    document = Document.find(params[:id])
    DocumentPublishingService.new.publish(document)
    redirect_to document, notice: t("pages.documents.show.flashes.publish_success")
  rescue GdsApi::BaseError => e
    document.update!(publication_state: "error_sending_to_live")
    Rails.logger.error(e)
    redirect_to document, alert: t("pages.documents.show.flashes.publish_error")
  end
end
