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
  end
end
