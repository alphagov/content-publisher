# frozen_string_literal: true

FactoryBot.define do
  factory :whitehall_migration do
    sequence(:id)
    organisation_content_id { "content_id" }
    document_type { "NewsArticle" }
    created_at { Time.current.rfc3339 }
    updated_at { Time.current.rfc3339 }
  end
end
