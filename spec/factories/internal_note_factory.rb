# frozen_string_literal: true

FactoryBot.define do
  factory :internal_note do
    body { "Amazing internal note" }
    edition
    association :created_by, factory: :user
  end
end
