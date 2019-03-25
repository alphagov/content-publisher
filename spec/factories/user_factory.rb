# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { "John Smith" }
    uid { SecureRandom.uuid }
    email { "someone@example.com" }

    trait :managing_editor do
      permissions { [User::MANAGING_EDITOR_PERMISSION] }
    end
  end
end
