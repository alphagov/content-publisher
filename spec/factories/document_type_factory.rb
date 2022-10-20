FactoryBot.define do
  factory :document_type do
    skip_create

    transient do
      rendering_app { nil }
      schema_name { nil }
    end

    id { SecureRandom.hex(4) }
    label { SecureRandom.alphanumeric(8) }
    tags { [] }
    guidance { [] }
    topics { false }
    attachments { "inline_file_only" }

    contents do
      [DocumentType::SummaryField.new]
    end

    publishing_metadata do
      DocumentType::PublishingMetadata.new(
        rendering_app:,
        schema_name:,
      )
    end

    initialize_with { new(attributes) }

    after(:build) do |document_type|
      DocumentType.all << document_type
    end

    trait :with_body do
      contents { [DocumentType::BodyField.new] }
    end

    trait :with_lead_image do
      lead_image { true }
    end

    trait :pre_release do
      pre_release { true }
    end
  end
end
