# frozen_string_literal: true

class DraftDocumentController < ApplicationController
  def create
    document = Document.find_by_param(params[:id])

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
end
