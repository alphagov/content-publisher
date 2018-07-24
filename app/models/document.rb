# frozen_string_literal: true

class Document < ApplicationRecord
  def document_type_schema
    DocumentTypeSchema.find(document_type)
  end
end
