# frozen_string_literal: true

class DocumentAssociationsController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    Rails.logger.error(e)
    render 'edit_api_down', status: 503
  end

  def edit
    @document = Document.find(params[:id])
  end

  def update
    document = Document.find(params[:id])
    document.update(associations: update_params(document))
    DocumentPublishingService.new.publish_draft(document)
    redirect_to document, notice: "Preview creation successful"
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
    redirect_to document, alert: "Error creating preview"
  end

private

  def update_params(document)
    permits = document.document_type_schema.associations.map do |schema|
      [schema.id, []]
    end

    params.fetch(:associations, {}).permit(Hash[permits])
  end
end
