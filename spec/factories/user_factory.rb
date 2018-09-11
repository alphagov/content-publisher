# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { "John Smith" }
    uid { SecureRandom.uuid }
  end
end
