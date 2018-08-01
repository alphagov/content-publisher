# frozen_string_literal: true

class Document < ActiveRecord::Base
  def document_type_schema
    DocumentTypeSchema.find(document_type)
  end
end
