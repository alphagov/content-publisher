# frozen_string_literal: true

FactoryBot.define do
  factory :field_schema, class: Hash do
    id { SecureRandom.hex(4) }
    label { SecureRandom.alphanumeric(4) }
    initialize_with { attributes.stringify_keys }
  end
end
