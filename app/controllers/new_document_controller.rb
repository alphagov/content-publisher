# frozen_string_literal: true

class NewDocumentController < ApplicationController
  def choose_supertype
    @supertypes = SupertypeSchema.all
  end

  def choose_document_type
    supertype_schema = SupertypeSchema.find(params[:supertype])

    if supertype_schema.managed_elsewhere
      redirect_to supertype_schema.managed_elsewhere_url
      return
    end

    @document_types = supertype_schema.document_types
  end

  def create
    document_type_schema = DocumentTypeSchema.find(params[:document_type])

    if document_type_schema.managed_elsewhere
      redirect_to document_type_schema.managed_elsewhere_url
      return
    end

    document = Document.create!(
      content_id: SecureRandom.uuid,
      locale: "en",
      document_type: params[:document_type],
    )

    redirect_to edit_document_path(document)
  end
end
