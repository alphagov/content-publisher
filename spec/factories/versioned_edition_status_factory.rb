# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_edition_status, class: Versioned::EditionStatus do
    user_facing_state { :draft }
    publishing_api_sync { :complete }
    association :created_by, factory: :user
    association :revision_at_creation, factory: :versioned_revision
  end
end
