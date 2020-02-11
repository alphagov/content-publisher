FactoryBot.define do
  factory :whitehall_export_index, class: "Hash" do
    skip_create

    documents { [build(:whitehall_export_index_document)] }

    page_count { documents.size }
    sequence(:page_number, 1)

    initialize_with { attributes.stringify_keys }
  end
end
