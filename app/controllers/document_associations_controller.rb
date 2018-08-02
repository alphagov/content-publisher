# frozen_string_literal: true

class DocumentAssociationsController < ApplicationController
  def edit
    @document = Document.find(params[:id])
  end

  def update
    @document = Document.find(params[:id])
    # @TODO there might not actually be any changes to save here
    @document.update_attribute(:associations, formatted_assocations)
    DocumentPublishingService.new.publish_draft(@document)
    redirect_to @document, notice: "Preview creation successful"
  rescue GdsApi::HTTPErrorResponse, SocketError => e
    Rails.logger.error(e)
    redirect_to @document, alert: "Error creating preview"
  end

private

  def update_params
    # As the fields might be arrays we can't just pass field names in as args
    params.require(:associations).permit!
  end

  def formatted_assocations
    @document.document_type_schema.associations.each_with_object({}) do |field, memo|
      next unless update_params[field.id]
      # @TODO there should probably be some sanity checks and storing of the
      # linkable name here
      memo[field.id] = update_params[field.id]
    end
  end
end
