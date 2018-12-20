# frozen_string_literal: true

class Document < ApplicationRecord
  has_paper_trail

  has_many :images, dependent: :destroy
  has_many :timeline_entries, dependent: :destroy
  has_many :internal_notes, dependent: :destroy

  belongs_to :lead_image, class_name: "Image", optional: true, foreign_key: :lead_image_id, inverse_of: :document
  belongs_to :creator, class_name: "User", optional: true, foreign_key: :creator_id, inverse_of: :documents
  belongs_to :last_editor, class_name: "User", optional: true, foreign_key: :last_editor_id, inverse_of: :documents

  delegate :topics, to: :document_topics

  PUBLICATION_STATES = %w[
    changes_not_sent_to_draft
    sent_to_draft
    error_sending_to_draft
    sent_to_live
    error_sending_to_live
    error_deleting_draft
  ].freeze

  REVIEW_STATES = %w[
    unreviewed
    submitted_for_review
    published_without_review
    reviewed
  ].freeze

  LIVE_STATES = %w[
    published
    retired
    removed
  ].freeze

  validates_inclusion_of :publication_state, in: PUBLICATION_STATES
  validates_inclusion_of :review_state, in: REVIEW_STATES
  validates_inclusion_of :live_state, in: LIVE_STATES, allow_nil: true, unless: :has_live_version_on_govuk
  validates_inclusion_of :update_type, in: %w[major minor], allow_nil: true

  def document_type
    DocumentType.find(document_type_id)
  end

  def newly_created?
    self.created_at == self.updated_at
  end

  def to_param
    content_id + ":" + locale
  end

  def self.find_by_param(content_id_and_locale)
    content_id, locale = content_id_and_locale.split(":")
    Document.find_by!(content_id: content_id, locale: locale)
  end

  def editable?
    publication_state != "sent_to_live"
  end

  def user_facing_state
    UserFacingState.new(self).to_s
  end

  def title_or_fallback
    title.presence || I18n.t!("documents.untitled_document")
  end

  def document_topics
    @document_topics_index ||= TopicIndexService.new
    DocumentTopics.find_by_document(self, @document_topics_index)
  end
end
