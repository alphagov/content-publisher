# frozen_string_literal: true

FactoryBot.define do
  factory :scheduling do
    reviewed { false }
    publish_time { Date.tomorrow.noon }
    association :pre_scheduled_status, factory: :status

    trait :failed do
      publish_time { Date.yesterday.noon }
    end
  end
end
