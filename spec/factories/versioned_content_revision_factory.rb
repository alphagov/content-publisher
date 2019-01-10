# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_content_revision, class: Versioned::ContentRevision do
    title { SecureRandom.alphanumeric(10) }
    base_path { title ? "/prefix/#{title.parameterize}" : nil }
    association :created_by, factory: :user
  end
end
