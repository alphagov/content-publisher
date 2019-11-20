# frozen_string_literal: true

FactoryBot.define do
  factory :whitehall_export_unpublishing, class: Hash do
    skip_create

    sequence(:id)
    created_at { Time.zone.now.rfc3339 }
    updated_at { Time.zone.now.rfc3339 }
    explanation { "User facing explanation" }
    alternative_url { "" }
    redirect { false }
    unpublishing_reason { "No longer current government policy/activity" }

    initialize_with { attributes.stringify_keys }
  end
end
