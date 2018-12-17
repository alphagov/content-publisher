# frozen_string_literal: true

class EditionsController < ApplicationController
  def create
    document = Document.find_by_param(params[:document_id])

    PreviewService.new(document).try_create_preview(
      user: current_user,
      type: "new_edition",
    )

    redirect_to edit_document_path(document)
  end
end
