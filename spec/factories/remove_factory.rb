# frozen_string_literal: true

FactoryBot.define do
  factory :remove do
    explanatory_note { SecureRandom.alphanumeric }
    alternative_path { explanatory_note ? "/prefix/#{explanatory_note.parameterize}" : nil }
  end
end
