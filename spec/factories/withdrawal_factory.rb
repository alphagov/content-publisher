# frozen_string_literal: true

FactoryBot.define do
  factory :withdrawal do
    public_explanation { SecureRandom.alphanumeric }
    withdrawn_at { Time.current }
  end
end
