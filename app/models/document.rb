# frozen_string_literal: true

class Document < ApplicationRecord
  PUBLICATION_STATES = %w[
    newly_created
    changes_not_sent_to_draft
    sending_to_draft
    sent_to_draft
    error_sending_to_draft
    publishing
    live_on_govuk
    error_in_publishing
  ].freeze

  validates_inclusion_of :publication_state, in: PUBLICATION_STATES

  def document_type_schema
    DocumentTypeSchema.find(document_type)
  end
end
