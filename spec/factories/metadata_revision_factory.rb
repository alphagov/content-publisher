# frozen_string_literal: true

FactoryBot.define do
  factory :metadata_revision do
    update_type { "major" }
    association :created_by, factory: :user
  end
end
