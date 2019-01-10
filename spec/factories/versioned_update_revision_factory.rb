# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_update_revision, class: Versioned::UpdateRevision do
    update_type { "major" }
    association :created_by, factory: :user
  end
end
