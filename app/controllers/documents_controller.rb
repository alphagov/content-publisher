# frozen_string_literal: true

class DocumentsController < ApplicationController
  rescue_from GdsApi::BaseError do |e|
    GovukError.notify(e)
    render "#{action_name}_api_down", status: :service_unavailable
  end

  def index
    filter = DocumentFilter.new(filter_params)
    @documents = filter.documents
    @filter_params = filter.filter_params
    @sort = filter.sort
  end

  def edit
    @document = Document.find_by_param(params[:id])
  end

  def show
    @document = Document.find_by_param(params[:id])
  end

  def confirm_delete_draft
    document = Document.find_by_param(params[:id])
    redirect_to document_path(document), confirmation: "documents/show/delete_draft"
  end

  def destroy
    Document.find_by_param(params[:id]).destroy!
    redirect_to documents_path
  end

  def update
    document = Document.find_by_param(params[:id])

    if document.publication_state == "sent_to_live"
      document.current_edition_number += 1
    end

    document.update!(update_params(document))
    TimelineEntry.create!(document: document, user: current_user, entry_type: "updated_content")
    DocumentPublishingService.new.publish_draft(document)
    redirect_to document
  rescue GdsApi::BaseError
    redirect_to document, alert_with_description: t("documents.show.flashes.draft_error")
  end

  def retry_draft_save
    document = Document.find_by_param(params[:id])
    DocumentPublishingService.new.publish_draft(document)
    redirect_to document
  rescue GdsApi::BaseError
    redirect_to document, alert_with_description: t("documents.show.flashes.draft_error")
  end

  def generate_path
    document = Document.find_by_param(params[:id])
    base_path = PathGeneratorService.new.path(document, params[:title])
    render plain: base_path
  rescue PathGeneratorService::ErrorGeneratingPath
    render status: :conflict
  end

private

  def filter_params
    {
      filters: params.permit(:title_or_url, :document_type, :state, :organisation).to_hash,
      sort: params[:sort],
      page: params[:page],
      per_page: 50,
    }
  end

  def update_params(document)
    DocumentUpdateParams.new(document).update_params(params)
      .merge(publication_state: "changes_not_sent_to_draft", review_state: "unreviewed")
  end
end
