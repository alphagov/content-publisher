# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { "John Smith" }
    uid { SecureRandom.uuid }

    trait :managing_editor do
      permissions { [User::MANAGING_EDITOR_PERMISSION] }
    end
  end
end
