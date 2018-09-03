# frozen_string_literal: true

class Document < ApplicationRecord
  has_many :images, dependent: :destroy
  belongs_to :creator, class_name: "User", optional: true, foreign_key: :creator_id, inverse_of: :documents

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

  def to_param
    content_id + ":" + locale
  end

  def self.find_by_param(content_id_and_locale)
    content_id, locale = content_id_and_locale.split(":")
    Document.find_by(content_id: content_id, locale: locale)
  end
end
