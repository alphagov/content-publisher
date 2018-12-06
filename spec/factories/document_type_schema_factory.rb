# frozen_string_literal: true

FactoryBot.define do
  factory :document_type_schema do
    id { SecureRandom.hex(4) }
    label { SecureRandom.alphanumeric(8) }
    document_type { SecureRandom.alphanumeric(8) }

    initialize_with do
      schema = DocumentTypeSchema.add_schema(attributes.stringify_keys)
      SupertypeSchema.all.first.document_types << schema
      schema
    end
  end
end
