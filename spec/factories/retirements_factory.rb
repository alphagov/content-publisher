# frozen_string_literal: true

FactoryBot.define do
  factory :retirement do
    explanatory_note { SecureRandom.alphanumeric }
  end
end
