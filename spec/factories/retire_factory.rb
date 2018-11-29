# frozen_string_literal: true

FactoryBot.define do
  factory :retire do
    explanatory_note { SecureRandom.alphanumeric }
  end
end
