# frozen_string_literal: true

class NewDocumentController < ApplicationController
  def choose_supertype
    @supertypes = YAML.load_file("app/formats/supertypes.yml")
  end

  def choose_document_type
    @document_types = YAML.load_file("app/formats/document_types.yml").select { |s| s["supertype"] == params[:supertype] }
  end
end
