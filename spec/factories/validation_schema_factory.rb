# frozen_string_literal: true

FactoryBot.define do
  factory :validation_schema, class: Hash do
    message { SecureRandom.alphanumeric(8) }
    initialize_with { attributes.stringify_keys }
  end
end
