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
    document.update_attributes(document_update_params(document))
    DocumentPublishingService.new.publish_draft(document)
    redirect_to document, notice: "Preview creation successful"
  rescue GdsApi::HTTPErrorResponse, SocketError => e
    Rails.logger.error(e)
    redirect_to document, alert: "Error creating preview"
  end

private

  def document_update_params(document)
    contents_params = document.document_type_schema.fields.map(&:id)
    params.require(:document).permit(:title, :base_path, contents: contents_params)
  end
end
