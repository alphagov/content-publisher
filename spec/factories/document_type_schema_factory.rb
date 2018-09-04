# frozen_string_literal: true

FactoryBot.define do
  factory :document_type_schema do
    id { SecureRandom.hex(4) }
    label { SecureRandom.alphanumeric(8) }
    document_type { SecureRandom.alphanumeric(8) }
    initialize_with { DocumentTypeSchema.create(attributes.stringify_keys) }
  end
end
