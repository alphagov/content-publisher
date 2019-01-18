# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_status, class: Versioned::Status do
    state { :draft }
    association :created_by, factory: :user
    association :revision_at_creation, factory: :versioned_revision
  end
end
