# frozen_string_literal: true

FactoryBot.define do
  factory :withdrawal do
    public_explanation { SecureRandom.alphanumeric }
  end
end
