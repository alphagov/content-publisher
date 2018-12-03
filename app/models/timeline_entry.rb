# frozen_string_literal: true

class TimelineEntry < ApplicationRecord
  belongs_to :document
  belongs_to :user, optional: true
  has_one :retirement, foreign_key: :timeline_entries_id, dependent: :destroy, inverse_of: :timeline_entry
  has_one :removal, foreign_key: :timeline_entries_id, dependent: :destroy, inverse_of: :timeline_entry

  ENTRY_TYPES = %w[
    created
    submitted
    updated_content
    published
    published_without_review
    approved
    updated_tags
    lead_image_updated
    lead_image_removed
    image_updated
    image_removed
    new_edition
    create_preview
    retired
    removed
  ].freeze

  validates_inclusion_of :entry_type, in: ENTRY_TYPES
  validate :can_only_have_one_associated_type

  def can_only_have_one_associated_type
    self.retirement.nil? || self.removal.nil?
  end

  def username_or_unknown
    user ? user.name : "Unknown user"
  end

  def self.create!(params)
    edition_number = params[:document].current_edition_number
    super(params.merge(edition_number: edition_number))
  end
end
