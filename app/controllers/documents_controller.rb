# frozen_string_literal: true

class DocumentsController < ApplicationController
  def index
    @documents = Document.all
  end

  def edit
    @document = Document.find(params[:id])
  end

  def show
    @document = Document.find(params[:id])
  end

  def update
    document = Document.find(params[:id])
    allowed_field_names_in_contents = document.document_type_schema.fields.map(&:id)
    document_update_params = params.require(:document).permit(:title, contents: allowed_field_names_in_contents)
    document.update_attributes(document_update_params)
    DocumentPublishingService.new.publish_draft(document)
    redirect_to edit_document_path(document), notice: "Preview creation successful"
  rescue StandardError
    redirect_to edit_document_path(document), alert: "Error creating preview"
  end

private

  def document_update_params
    params.require(:document).permit(:title)
  end
end
