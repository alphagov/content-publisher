# frozen_string_literal: true

FactoryBot.define do
  factory :whitehall_export_user, class: Hash do
    skip_create

    sequence(:id)
    name { "Joe Bloggs" }
    uid { SecureRandom.uuid }
    email { "joe@example.com" }
    organisation_slug { "a-government-department" }
    organisation_content_id { SecureRandom.uuid }

    initialize_with { attributes.stringify_keys }
  end
end
