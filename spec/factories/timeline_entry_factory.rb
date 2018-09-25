# frozen_string_literal: true

FactoryBot.define do
  factory :timeline_entry do
    document
    user
    entry_type { TimelineEntry::ENTRY_TYPES.sample }
    edition_number { (rand * 100).to_i }
  end
end
