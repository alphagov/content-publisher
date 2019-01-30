# frozen_string_literal: true

FactoryBot.define do
  factory :document_type do
    skip_create

    id { SecureRandom.hex(4) }
    label { SecureRandom.alphanumeric(8) }
    contents { [] }
    tags { [] }
    guidance { [] }
    publishing_metadata { DocumentType::PublishingMetadata.new }
    initialize_with { new(attributes) }

    after(:build) do |document_type|
      DocumentType.all << document_type
      Supertype.all.first.document_types << document_type
    end
  end
end
