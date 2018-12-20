# frozen_string_literal: true

class InternalNote < ApplicationRecord
  belongs_to :document
  belongs_to :user, optional: true
  belongs_to :timeline_entry, class_name: "TimelineEntry", foreign_key: :timeline_entries_id, inverse_of: :internal_note
end
