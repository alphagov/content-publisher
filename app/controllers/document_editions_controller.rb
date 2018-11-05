# frozen_string_literal: true

class DocumentEditionsController < ApplicationController
  def create
    document = Document.find_by_param(params[:document_id])

    DocumentDraftingService.update!(
      document: document,
      user: current_user,
      type: "new_edition",
    )

    redirect_to edit_document_path(document)
  end
end
