# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_internal_note, class: Versioned::InternalNote do
    body { "Amazing internal note" }
    association :edition, factory: :versioned_edition
    association :created_by, factory: :user
  end
end
