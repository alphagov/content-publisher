FactoryBot.define do
  factory :whitehall_migration do
    organisation_content_id { SecureRandom.uuid }
    document_type { "NewsArticle" }
    created_at { Time.current.rfc3339 }
    updated_at { Time.current.rfc3339 }
  end
end
