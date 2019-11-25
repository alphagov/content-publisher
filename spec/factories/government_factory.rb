# frozen_string_literal: true

FactoryBot.define do
  factory :government, class: Government do
    skip_create

    content_id { SecureRandom.uuid }
    name { SecureRandom.alphanumeric(8) }
    slug { name.parameterize }
    start_date { Date.parse("2015-05-08") }
    end_date { nil }
    initialize_with { new(attributes) }
  end
end
