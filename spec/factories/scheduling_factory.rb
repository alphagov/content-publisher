# frozen_string_literal: true

FactoryBot.define do
  factory :scheduling do
    reviewed { false }
    publish_time { Time.current.advance(days: 2) }
    association :pre_scheduled_status, factory: :status
  end
end
