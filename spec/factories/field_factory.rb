# frozen_string_literal: true

FactoryBot.define do
  factory :field do
    skip_create

    id { SecureRandom.hex(4) }
    label { SecureRandom.alphanumeric(4) }
    initialize_with { new(attributes) }
  end
end
