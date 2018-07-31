# frozen_string_literal: true

class DocumentAssociationsController < ApplicationController
  before_action :check_document_supports_associations

  def edit;end

  def update
  end

private

  def check_document_supports_associations
    @document = Document.find(params[:id])
    document_type = @document.document_type_schema

    unless document_type.associations?
      # @TODO maybe switch this out for one of our exceptions it feels like
      # the wrong one to use
      raise ActionController::RoutingError, "#{document_type.name} does not support assocations"
    end
  end
end
