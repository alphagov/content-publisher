# frozen_string_literal: true

class NewDocumentController < ApplicationController
  def choose_supertype
    @supertypes = SupertypeSchema.all
  end

  def choose_document_type
    unless params[:supertype]
      redirect_to new_document_path,
        alert: t("new_document.choose_supertype.flashes.choose_error")

      return
    end

    @supertype_schema = SupertypeSchema.find(params[:supertype])

    if @supertype_schema.managed_elsewhere
      redirect_to @supertype_schema.managed_elsewhere_url
      return
    end

    @document_types = @supertype_schema.document_types
  end

  def create
    unless params[:document_type]
      redirect_to choose_document_type_path(supertype: params[:supertype]),
        alert: t("new_document.choose_document_type.flashes.choose_error")

      return
    end

    document_type_schema = DocumentTypeSchema.find(params[:document_type])

    if document_type_schema.managed_elsewhere
      redirect_to document_type_schema.managed_elsewhere_url
      return
    end

    document = Document.create!(
      content_id: SecureRandom.uuid,
      locale: "en",
      document_type: params[:document_type],
      publication_state: "changes_not_sent_to_draft",
    )

    redirect_to edit_document_path(document)
  end
end
