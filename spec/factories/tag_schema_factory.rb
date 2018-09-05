# frozen_string_literal: true

FactoryBot.define do
  factory :tag_schema, class: Hash do
    id { SecureRandom.hex(4) }
    document_type { SecureRandom.alphanumeric(8) }
    initialize_with { attributes.stringify_keys }
  end
end
