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
    document_attributes = document_update_params(document)
    document_attributes[:base_path] = generate_base_path(document, document.title)
    document.update_attributes(document_attributes)
    DocumentPublishingService.new.publish_draft(document)
    redirect_to document, notice: "Preview creation successful"
  rescue GdsApi::HTTPErrorResponse, SocketError => e
    Rails.logger.error(e)
    redirect_to document, alert: "Error creating preview"
  end

  def generate_path
    document = Document.find(params[:id])
    proposed_title = params[:title]
    base_path = generate_base_path(document, proposed_title)
    if path_in_publishing_api?(base_path)
      render json: { base_path: base_path, available: false }
    else
      render json: { base_path: base_path, available: true }
    end
  end

private

  def generate_base_path(document, title)
    base_path = DocumentPublishingService.new.generate_base_path(document, title)
    raise "Duplicate path error" if path_in_publishing_api?(base_path)
    base_path
  end

  def path_in_publishing_api?(base_path)
    publishing_service = DocumentPublishingService.new
    publishing_service.path_exists?(base_path)
  end

  def document_update_params(document)
    contents_params = document.document_type_schema.contents.map(&:id)
    params.require(:document).permit(:title, :summary, contents: contents_params)
  end
end
