# frozen_string_literal: true

FactoryBot.define do
  factory :user do
    name { SecureRandom.alphanumeric(8) }
    organisation_content_id { SecureRandom.uuid }
  end
end
