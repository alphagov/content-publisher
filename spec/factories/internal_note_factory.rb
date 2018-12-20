# frozen_string_literal: true

FactoryBot.define do
  factory :internal_note do
    body { "Amazing internal note" }
    document
    user
    timeline_entry
  end
end
