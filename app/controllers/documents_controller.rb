# frozen_string_literal: true

class DocumentsController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    Rails.logger.error(e)
    render "#{action_name}_api_down", status: :service_unavailable
  end

  def index
    @documents = Document.page(params[:page]).per(50)
  end

  def edit
    @document = Document.find_by_param(params[:id])
  end

  def show
    @document = Document.find_by_param(params[:id])
  end

  def update
    document = Document.find_by_param(params[:id])
    before = document.as_json
    document.update!(update_params(document))
    after = document.as_json
    Event::DocumentUpdated.create!(
      document: document,
      user: current_user,
      before: before,
      after: after,
    )

    DocumentPublishingService.new.publish_draft(document)
    redirect_to document, notice: t("documents.show.flashes.draft_success")
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
    document.update!(publication_state: "error_sending_to_draft")
    redirect_to document, alert: t("documents.show.flashes.draft_error")
  end

  def generate_path
    document = Document.find_by_param(params[:id])
    base_path = PathGeneratorService.new.path(document, params[:title])
    render plain: base_path
  rescue PathGeneratorService::ErrorGeneratingPath
    render status: :conflict
  end

private

  def update_params(document)
    contents_params = document.document_type_schema.contents.map(&:id)
    base_path = PathGeneratorService.new.path(document, params[:document][:title])

    params.require(:document).permit(:title, :summary, contents: contents_params)
      .merge(base_path: base_path, publication_state: "changes_not_sent_to_draft", review_state: "unreviewed")
  end
end
