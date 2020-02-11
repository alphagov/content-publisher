FactoryBot.define do
  factory :whitehall_export_fact_check_event, class: "Hash" do
    skip_create

    sequence(:id)
    sequence(:edition_id)
    key { "redacted-1" }
    email_address { "someone@somewhere.com" }
    instructions { "Do something" }
    comments { "hello" }
    sequence(:requestor_id)
    created_at { Time.current.rfc3339 }
    updated_at { Time.current.rfc3339 }

    initialize_with { attributes.stringify_keys }
  end
end
