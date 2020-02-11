FactoryBot.define do
  factory :whitehall_export_editorial_remark_event, class: "Hash" do
    skip_create

    sequence(:id)
    body { "Note about the revision" }
    sequence(:author_id)
    created_at { Time.current.rfc3339 }

    initialize_with { attributes.stringify_keys }
  end
end
