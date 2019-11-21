# frozen_string_literal: true

FactoryBot.define do
  factory :whitehall_export_document, class: Hash do
    skip_create

    sequence(:id)
    created_at { Time.zone.now.rfc3339 }
    updated_at { Time.zone.now.rfc3339 }
    slug { SecureRandom.alphanumeric(10).parameterize }
    content_id { SecureRandom.uuid }
    editions { [build(:whitehall_export_edition)] }
    users { [build(:whitehall_export_user)] }

    initialize_with { attributes.stringify_keys }
  end
end
