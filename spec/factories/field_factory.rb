# frozen_string_literal: true

FactoryBot.define do
  factory :field, class: DocumentType::Field do
    id { SecureRandom.hex(4) }
    label { SecureRandom.alphanumeric(4) }
  end
end
