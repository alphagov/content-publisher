# frozen_string_literal: true

FactoryBot.define do
  factory :status do
    state { :draft }
    association :created_by, factory: :user
    association :revision_at_creation, factory: :revision

    trait :withdrawn do
      state { :withdrawn }

      transient do
        withdrawn_at { Time.current }
      end

      association :details, factory: :withdrawal
      after(:build) do |status, evaluator|
        status.details = evaluator.association(
          :withdrawal,
          withdrawn_at: evaluator.withdrawn_at,
        )
      end
    end
  end
end
