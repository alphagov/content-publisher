# frozen_string_literal: true

FactoryBot.define do
  factory :removal do
    explanatory_note { SecureRandom.alphanumeric }
    alternative_path { "/prefix/#{SecureRandom.alphanumeric}" }
  end
end
