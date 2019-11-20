# frozen_string_literal: true

FactoryBot.define do
  factory :whitehall_export_organisation, class: Hash do
    skip_create

    sequence(:id)
    content_id { SecureRandom.uuid }
    trait :lead do
      lead { "true" }
      lead_ordering { 1 }
    end

    initialize_with { attributes.stringify_keys }
  end
end
