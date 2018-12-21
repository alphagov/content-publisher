# frozen_string_literal: true

class Retirement < ApplicationRecord
  belongs_to :timeline_entry, class_name: "TimelineEntry", foreign_key: :timeline_entries_id, inverse_of: :retirement
  belongs_to :document
  validates_inclusion_of :entry_type, in: %w[retired]

  def entry_type
    self.timeline_entry.entry_type
  end
end
