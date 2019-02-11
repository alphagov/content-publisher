# frozen_string_literal: true

FactoryBot.define do
  factory :status do
    state { :draft }
    association :created_by, factory: :user
    association :revision_at_creation, factory: :revision

    trait :withdrawn do
      state { :withdrawn }

      transient do
        public_explanation { SecureRandom.alphanumeric }
        withdrawn_at { Time.current }
      end

      association :details, factory: :withdrawal
      after(:build) do |status, evaluator|
        status.details = evaluator.association(
          :withdrawal,
          withdrawn_at: evaluator.withdrawn_at,
          public_explanation: evaluator.public_explanation,
        )
      end
    end

    trait :published do
      state { :published }
    end
  end
end
