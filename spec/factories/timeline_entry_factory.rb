# frozen_string_literal: true

FactoryBot.define do
  factory :timeline_entry do
    entry_type { "internal_note" }
    document
    user
    edition_number { 1 }
  end
end
