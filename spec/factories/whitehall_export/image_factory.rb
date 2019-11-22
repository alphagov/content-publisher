# frozen_string_literal: true

FactoryBot.define do
  factory :whitehall_export_image, class: Hash do
    skip_create

    sequence(:id)
    alt_text { "Alt text for image" }
    caption { "This is a caption" }
    created_at { Time.zone.now.rfc3339 }
    updated_at { Time.zone.now.rfc3339 }
    variants { {} }
    url { "https://assets.publishing.service.gov.uk/government/uploads/#{filename}" }

    transient do
      fixture_file { "960x640.jpg" }
      filename { "valid-image.jpg" }
    end

    initialize_with do
      attributes.stringify_keys
    end

    after(:build) do |image, evaluator|
      WebMock.stub_request(:get, image["url"]).to_return(
        status: 200,
        body: lambda { |_request|
          File.open(Rails.root.join("spec", "fixtures", "files", evaluator.fixture_file), "rb").read
        },
      )
    end
  end
end
