# frozen_string_literal: true

class DocumentEditionsController < ApplicationController
  def create
    document = Document.find_by_param(params[:document_id])
    document.update!(change_note: nil, update_type: "major")
    redirect_to edit_document_path(document)
  end
end
