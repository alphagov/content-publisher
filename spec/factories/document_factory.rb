# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    content_id { SecureRandom.uuid }
    locale { I18n.available_locales.sample }
    document_type_id { build(:document_type, path_prefix: "/prefix").id }
    association :created_by, factory: :user

    trait :with_live_edition do
      after(:build) do |document, evaluator|
        document.live_edition = evaluator.association(
          :edition,
          :published,
          created_by: document.created_by,
          current: true,
          live: true,
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
          current: true,
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
          live: true,
          document: document,
        )

        document.current_edition = evaluator.association(
          :edition,
          created_by: document.created_by,
          current: true,
          document: document,
        )
      end
    end
  end
end
