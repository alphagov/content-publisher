# frozen_string_literal: true

class Document < ApplicationRecord
  has_many :images, dependent: :destroy

  PUBLICATION_STATES = %w[
    changes_not_sent_to_draft
    sending_to_draft
    sent_to_draft
    error_sending_to_draft
    sending_to_live
    sent_to_live
    error_sending_to_live
  ].freeze

  validates_inclusion_of :publication_state, in: PUBLICATION_STATES

  def document_type_schema
    DocumentTypeSchema.find(document_type)
  end

  def newly_created?
    self.created_at == self.updated_at
  end
end
