# frozen_string_literal: true

FactoryBot.define do
  factory :withdrawal do
    explanatory_note { SecureRandom.alphanumeric }
  end
end
