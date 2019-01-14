# frozen_string_literal: true

FactoryBot.define do
  factory :image do
    association :created_by, factory: :user
  end
end
