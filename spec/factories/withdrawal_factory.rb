# frozen_string_literal: true

FactoryBot.define do
  factory :withdrawal do
    public_explanation { SecureRandom.alphanumeric }
    withdrawn_at { Date.yesterday.noon }

    association :published_status, :published, factory: :status
  end
end
