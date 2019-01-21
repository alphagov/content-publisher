# frozen_string_literal: true

FactoryBot.define do
  factory :tags_revision do
    association :created_by, factory: :user
  end
end
