FactoryBot.define do
  factory :whitehall_export_revision_history_event, class: "Hash" do
    skip_create

    sequence(:id)
    event { "create" }
    state { "draft" }
    sequence(:whodunnit)
    created_at { Time.current.rfc3339 }

    initialize_with { attributes.stringify_keys }
  end
end
