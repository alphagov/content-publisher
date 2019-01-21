# frozen_string_literal: true

FactoryBot.define do
  factory :update_revision do
    update_type { "major" }
    association :created_by, factory: :user
  end
end
