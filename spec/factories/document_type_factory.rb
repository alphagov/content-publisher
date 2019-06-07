# frozen_string_literal: true

FactoryBot.define do
  factory :document_type do
    skip_create

    transient do
      rendering_app { nil }
      schema_name { nil }
    end

    id { SecureRandom.hex(4) }
    label { SecureRandom.alphanumeric(8) }
    contents { [] }
    tags { [] }
    guidance { [] }

    publishing_metadata do
      DocumentType::PublishingMetadata.new(
        rendering_app: rendering_app,
        schema_name: schema_name,
      )
    end

    initialize_with { new(attributes) }

    after(:build) do |document_type|
      DocumentType.all << document_type
      Supertype.all.first.document_types << document_type
    end
  end
end
