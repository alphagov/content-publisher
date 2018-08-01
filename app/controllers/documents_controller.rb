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

  def generate_path
    publishing_service = DocumentPublishingService.new
    base_path = publishing_service.generate_base_path(params[:title])
    reservation_response = publishing_service.reserve_path(base_path)
    if path_reserved?(reservation_response)
      render json: { base_path: base_path, reserved: true }
    else
      render json: { base_path: base_path, reserved: false }
    end
  end

private

  def path_reserved?(response)
    response.status == 200
  end

  def document_update_params(document)
    contents_params = document.document_type_schema.contents.map(&:id)
    params.require(:document).permit(:title, :summary, :base_path, contents: contents_params)
  end
end
