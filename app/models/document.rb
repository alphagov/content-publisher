# frozen_string_literal: true

class Document < ApplicationRecord
  validates_inclusion_of :publication_state, in: PublicationState::STATES

  def document_type_schema
    DocumentTypeSchema.find(document_type)
  end
end
