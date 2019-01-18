# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_image, class: Versioned::Image do
    association :created_by, factory: :user
  end
end
