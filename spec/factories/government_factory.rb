FactoryBot.define do
  factory :government, class: "Government" do
    skip_create

    transient do
      started_on { Date.parse("2015-05-08") }
      ended_on { nil }
      current { ended_on.nil? }
    end

    content_id { SecureRandom.uuid }
    locale { "en" }
    title { SecureRandom.alphanumeric(8) }

    details do
      {
        "started_on" => started_on.rfc3339,
        "ended_on" => ended_on&.rfc3339,
        "current" => current,
      }
    end

    trait :past do
      started_on { Date.parse("2010-05-12") }
      ended_on { Date.parse("2015-05-08") }
    end

    initialize_with { new(attributes.stringify_keys) }
  end
end
