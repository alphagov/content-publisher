# frozen_string_literal: true

FactoryBot.define do
  factory :guidance, class: Hash do
    skip_create

    title { SecureRandom.alphanumeric(8) }
    body { SecureRandom.alphanumeric(8) }
    initialize_with { attributes.stringify_keys }
  end
end
