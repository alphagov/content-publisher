# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    content_id { SecureRandom.uuid }
    locale { I18n.available_locales.sample }
    association :created_by, factory: :user

    trait :with_live_edition do
      after(:build) do |document, evaluator|
        document.live_edition = evaluator.association(
          :edition,
          :published,
          created_by: document.created_by,
          document: document,
        )
        document.current_edition = document.live_edition
      end
    end

    trait :with_current_edition do
      after(:build) do |document, evaluator|
        document.current_edition = evaluator.association(
          :edition,
          created_by: document.created_by,
          document: document,
        )
      end
    end

    trait :with_current_and_live_editions do
      after(:build) do |document, evaluator|
        document.live_edition = evaluator.association(
          :edition,
          :published,
          created_by: document.created_by,
          current: false,
          document: document,
        )

        document.current_edition = evaluator.association(
          :edition,
          created_by: document.created_by,
          document: document,
        )
      end
    end
  end
end
