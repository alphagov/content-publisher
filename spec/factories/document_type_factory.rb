# frozen_string_literal: true

FactoryBot.define do
  factory :document_type do
    skip_create

    transient do
      rendering_app { nil }
      schema_name { nil }
    end

    id { SecureRandom.hex(4) }
    contents { [] }
    tags { [] }
    guidance { [] }
    topics { false }

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
      en = { document_types: { document_type.id.to_sym => { label: document_type.id } } }
      I18n.backend.store_translations(:en, en)
    end
  end
end
