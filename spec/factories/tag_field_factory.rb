FactoryBot.define do
  factory :tag_field, class: "DocumentType::TagField" do
    skip_create

    id { SecureRandom.hex(4) }
    document_type { SecureRandom.alphanumeric(8) }
    initialize_with { new(attributes) }

    trait :primary_publishing_organisation do
      id { "primary_publishing_organisation" }
      type { "single_tag" }
    end

    trait :world_locations do
      id { "world_locations" }
      type { "multi_tag" }
    end
  end
end
