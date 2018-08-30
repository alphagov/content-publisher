# frozen_string_literal: true

class DocumentAssociationsController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    Rails.logger.error(e)
    render "edit_api_down", status: :service_unavailable
  end

  def edit
    @document = Document.find(params[:id])
  end

  def update
    document = Document.find(params[:id])
    document.update(associations: update_params(document))
    DocumentPublishingService.new.publish_draft(document)
    redirect_to document, notice: t("documents.show.flashes.draft_success")
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
    redirect_to document, alert: t("documents.show.flashes.draft_error")
  end

private

  def update_params(document)
    permits = document.document_type_schema.associations.map do |schema|
      [schema.id, []]
    end

    params.fetch(:associations, {}).permit(Hash[permits])
  end
end
