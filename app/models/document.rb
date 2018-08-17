# frozen_string_literal: true

class Document < ApplicationRecord
  validates_inclusion_of :publication_state, in: PublicationStateSchema.all.map(&:id)

  def document_type_schema
    DocumentTypeSchema.find(document_type)
  end

  def publication_state_schema
    PublicationStateSchema.find(publication_state)
  end
end
