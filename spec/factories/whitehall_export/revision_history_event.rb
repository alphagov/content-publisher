# frozen_string_literal: true

FactoryBot.define do
  factory :whitehall_export_revision_history_event, class: Hash do
    skip_create

    event { "create" }
    state { "draft" }
    whodunnit { 1 }
    created_at { Time.current.rfc3339 }

    initialize_with { attributes.stringify_keys }
  end
end
