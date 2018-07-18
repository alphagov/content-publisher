# frozen_string_literal: true

class DocumentsController < ApplicationController
  def index
    @documents = Document.all
  end

  def choose_format; end

  def history
    @document = Document.find(params[:id])
  end

  def summary
    @document = Document.find(params[:id])
  end

  def create
    document = Document.create!(
      content_id: SecureRandom.uuid,
      locale: "en",
      document_type: params[:document_type],
      current_edition_number: 1,
      publication_state: "unpublished-edits",
    )

    redirect_to edit_document_path(document)
  end

  def edit
    @document = Document.find(params[:id])
  end

  def update
    document = Document.find(params[:id])
    params = { publication_state: "unpublished-edits" }.merge(document_update_params)
    document.update_attributes(params)
    redirect_to document_path(document)
  end

  def publish
    document = Document.find(params[:id])
    document.update(publication_state: "published-to-live", current_edition_number: document.current_edition_number + 1)
    redirect_to document_path(document)
  end

  def roll_back_to_version
    version = PaperTrail::Version.find(params[:id]).next.reify
    document = Document.find(version.id)
    document.update_attributes({ publication_state: "unpublished-edits" }.merge(title: version.title, description: version.description))
    redirect_to document_path(document)
  end

private

  def document_update_params
    params.require(:document).permit(:title, :description)
  end
end
