# frozen_string_literal: true

FactoryBot.define do
  factory :association, class: Hash do
    id { SecureRandom.hex(4) }
    document_type { SecureRandom.alphanumeric(8) }
  end
end
