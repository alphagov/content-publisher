# frozen_string_literal: true

FactoryBot.define do
  factory :tag_field, class: DocumentType::TagField do
    id { SecureRandom.hex(4) }
    document_type { SecureRandom.alphanumeric(8) }
  end
end
