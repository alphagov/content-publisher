FactoryBot.define do
  factory :whitehall_export_index_document, class: "Hash" do
    skip_create

    sequence(:document_id)

    document_information {
      {
        locales: %w(en),
        sub_types: %w(news_story),
        lead_organisations: %w(96ae61d6-c2a1-48cb-8e67-da9d105ae381),
      }.stringify_keys
    }

    initialize_with { attributes.stringify_keys }
  end
end
