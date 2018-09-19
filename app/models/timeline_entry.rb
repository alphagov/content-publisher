# frozen_string_literal: true

class TimelineEntry < ApplicationRecord
  belongs_to :document
  belongs_to :user

  ENTRY_TYPES = %w[updated_content updated_tags submitted published_without_review approved].freeze
  validates_presence_of :entry_type, in: ENTRY_TYPES

  def username_or_unknown
    user ? user.name : "Unknown user"
  end

  def self.create!(params)
    edition_number = params[:document].current_edition_number
    super(params.merge(edition_number: edition_number))
  end
end
