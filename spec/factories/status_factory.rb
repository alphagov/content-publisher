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

    trait :published_but_needs_2i do
      state { :published_but_needs_2i }
    end

    trait :removed do
      state { :removed }

      transient do
        removal { nil }
      end

      after(:build) do |status, evaluator|
        status.details = evaluator.removal || evaluator.association(:removal)
      end
    end

    trait :scheduled do
      state { :scheduled }

      transient do
        scheduling { nil }
        publish_time { Date.tomorrow.noon }
      end

      after(:build) do |status, evaluator|
        new_scheduling = evaluator.association(:scheduling,
                                               publish_time: evaluator.publish_time)
        status.details = evaluator.scheduling || new_scheduling
      end
    end

    trait :failed_to_publish do
      state { :failed_to_publish }

      transient do
        scheduling { nil }
      end

      after(:build) do |status, evaluator|
        status.details = evaluator.scheduling || evaluator.association(:scheduling, :failed)
      end
    end
  end
end
