# frozen_string_literal: true

class Retire < ApplicationRecord
  belongs_to :timeline_entry, class_name: "TimelineEntry", foreign_key: :timeline_entries_id, inverse_of: :retire
end
