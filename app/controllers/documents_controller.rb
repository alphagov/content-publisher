# frozen_string_literal: true

class DocumentsController < ApplicationController
  def index
    @documents = Document.all
  end

  def edit
    @document = Document.find(params[:id])
  end

  def update
    document = Document.find(params[:id])
    document.update_attributes(document_update_params)
    redirect_to edit_document_path(document)
  end

private

  def document_update_params
    params.require(:document).permit(:title)
  end
end
