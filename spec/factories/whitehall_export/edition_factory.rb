# frozen_string_literal: true

FactoryBot.define do
  factory :whitehall_export_edition, class: Hash do
    skip_create

    sequence(:id)
    created_at { Time.zone.now.rfc3339 }
    updated_at { Time.zone.now.rfc3339 }
    access_limited { false }
    change_note { "First published" }
    state { "draft" }
    minor_change { false }
    news_article_type { "news_story" }
    force_published { false }
    translations { [build(:whitehall_export_translation)] }
    organisations { [build(:whitehall_export_organisation, :lead)] }
    role_appointments { [] }
    topical_events { [] }
    world_locations { [] }
    contacts { [] }
    images { [] }
    revision_history do
      [
        { "event" => "create", "state" => state, "whodunnit" => 1 },
      ]
    end
    unpublishing { nil }

    initialize_with { attributes.stringify_keys }
  end
end
