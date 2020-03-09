FactoryBot.define do
  factory :whitehall_export_index_document, class: "Hash" do
    skip_create

    sequence(:document_id)

    content_id { SecureRandom.uuid }

    initialize_with { attributes.stringify_keys }
  end
end
