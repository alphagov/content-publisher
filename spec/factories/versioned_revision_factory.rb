# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_revision, class: Versioned::Revision do
    title { SecureRandom.alphanumeric(10) }
    base_path { title ? "/prefix/#{title.parameterize}" : nil }
    association :created_by, factory: :user
    association :document, factory: :versioned_document
  end
end
