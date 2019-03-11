# frozen_string_literal: true

FactoryBot.define do
  factory :status do
    state { :draft }
    association :created_by, factory: :user
    association :revision_at_creation, factory: :revision

    trait :withdrawn do
      state { :withdrawn }

      transient do
        withdrawal { nil }
      end

      after(:build) do |status, evaluator|
        status.details = evaluator.withdrawal || evaluator.association(:withdrawal)
      end
    end

    trait :published do
      state { :published }
    end

    trait :scheduled do
      state { :scheduled }

      transient do
        scheduling { nil }
      end

      after(:build) do |status, evaluator|
        status.details = evaluator.scheduling || evaluator.association(:scheduling)
      end
    end
  end
end
