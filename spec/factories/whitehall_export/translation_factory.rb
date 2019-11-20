# frozen_string_literal: true

FactoryBot.define do
  factory :whitehall_export_translation, class: Hash do
    skip_create

    sequence(:id)
    locale { "en" }
    title { "Title" }
    summary { "Summary" }
    body { "Body" }
    base_path { "/government/news/#{title.parameterize}" }

    initialize_with { attributes.stringify_keys }
  end
end
