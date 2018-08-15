# frozen_string_literal: true

class DocumentsController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    Rails.logger.error(e)
    render 'show_api_down', status: 503
  end

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
    document.update!(update_params(document))
    DocumentPublishingService.new.publish_draft(document)
    redirect_to document, notice: t("documents.show.flashes.draft_success")
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
    document.update!(publication_state: "error_sending_to_draft")
    redirect_to document, alert: t("documents.show.flashes.draft_error")
  end

  def generate_path
    document = Document.find(params[:id])
    base_path = PathGeneratorService.new.path(document, params[:title])
    render json: { base_path: base_path, available: true }
  rescue PathGeneratorService::ErrorGeneratingPath
    render json: { available: false }, status: 409
  end

private

  def update_params(document)
    contents_params = document.document_type_schema.contents.map(&:id)
    base_path = PathGeneratorService.new.path(document, params[:document][:title])

    params.require(:document).permit(:title, :summary, contents: contents_params)
      .merge(base_path: base_path, publication_state: "changes_not_sent_to_draft")
  end
end
