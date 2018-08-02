# frozen_string_literal: true

class DocumentAssociationsController < ApplicationController
  attr_reader :document
  before_action :check_document_supports_associations

  def update
    # @TODO there might not actually be any changes to save here
    document.update_attribute(:associations, formatted_assocations)
    DocumentPublishingService.new.publish_draft(document)
    redirect_to document, notice: "Preview creation successful"
  rescue GdsApi::HTTPErrorResponse, SocketError => e
    Rails.logger.error(e)
    redirect_to document, alert: "Error creating preview"
  end

private

  def check_document_supports_associations
    @document = Document.find(params[:id])
    document_type = document.document_type_schema

    unless document_type.associations?
      # @TODO maybe switch this out for one of our exceptions it feels like
      # the wrong one to use
      raise ActionController::RoutingError, "#{document_type.name} does not support assocations"
    end
  end

  def update_params
    # As the fields might be arrays we can't just pass field names in as args
    params.require(:associations).permit!
  end

  def formatted_assocations
    document.document_type_schema.associations.each_with_object({}) do |field, memo|
      next unless update_params[field.id]
      # @TODO there should probably be some sanity checks and storing of the
      # linkable name here
      memo[field.id] = update_params[field.id]
    end
  end
end
