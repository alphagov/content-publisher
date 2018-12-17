# frozen_string_literal: true

FactoryBot.define do
  factory :document_type do
    id { SecureRandom.hex(4) }
    label { SecureRandom.alphanumeric(8) }
    contents { [] }
    tags { [] }
    guidance { [] }
    publishing_metadata { DocumentType::PublishingMetadata.new }

    initialize_with do
      document_type = DocumentType.add(attributes)
      Supertype.all.first.document_types << document_type
      document_type
    end
  end
end
