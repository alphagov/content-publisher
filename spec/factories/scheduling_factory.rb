# frozen_string_literal: true

FactoryBot.define do
  factory :scheduling do
    reviewed { false }
    association :pre_scheduled_status, factory: :status
  end
end
