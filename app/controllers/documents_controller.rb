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
    save_base_path!(document)
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

  def save_base_path!(document)
    base_path = generate_base_path(document, document.title)
    # TODO: Generate a base_path which isn't in use
    return false if path_in_publishing_api?(base_path)
    document.base_path = base_path
    document.save!
  end

  def generate_base_path(document, title)
    DocumentPublishingService.new.generate_base_path(document, title)
  end

  def path_in_publishing_api?(base_path)
    publishing_service = DocumentPublishingService.new
    publishing_service.path_exists?(base_path)
  end

  def document_update_params(document)
    contents_params = document.document_type_schema.contents.map(&:id)
    params.require(:document).permit(:title, :summary, :base_path, contents: contents_params)
  end
end
