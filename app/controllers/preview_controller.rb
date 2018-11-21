# frozen_string_literal: true

class PreviewController < ApplicationController
  def create
    document = Document.find_by_param(params[:id])

    if Requirements::DocumentChecker.new(document).pre_preview_issues.any?
      redirect_to document_path(document), tried_to_preview: true
      return
    end

    DocumentDraftingService.update!(
      document: document,
      user: current_user,
      type: "create_preview",
    )

    redirect_to preview_document_path(document)
  rescue GdsApi::BaseError => e
    Rails.logger.error(e)
    redirect_to document_path(document), alert_with_description: t("documents.show.flashes.preview_error")
  end

  def show
    @document = Document.find_by_param(params[:id])
  end
end
