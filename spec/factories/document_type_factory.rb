# frozen_string_literal: true

FactoryBot.define do
  factory :document_type do
    id { SecureRandom.hex(4) }
    label { SecureRandom.alphanumeric(8) }

    initialize_with do
      document_type = DocumentType.add(attributes.stringify_keys)
      Supertype.all.first.document_types << document_type
      document_type
    end
  end
end
