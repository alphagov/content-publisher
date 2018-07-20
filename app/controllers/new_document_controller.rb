# frozen_string_literal: true

class NewDocumentController < ApplicationController
  def choose_supertype
    @supertypes = YAML.load_file("app/formats/supertypes.yml")
  end

  def choose_document_type
    @document_types = YAML.load_file("app/formats/document_types.yml").select { |s| s["supertype"] == params[:supertype] }
  end

  def create
    document = Document.create!(
      content_id: SecureRandom.uuid,
      locale: "en",
      document_type: params[:document_type],
    )

    redirect_to edit_document_path(document)
  end
end
