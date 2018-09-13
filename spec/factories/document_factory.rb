# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    content_id { SecureRandom.uuid }
    locale { I18n.available_locales.sample }
    title { SecureRandom.alphanumeric(10) }
    base_path { title ? "/prefix/#{title.parameterize}" : nil }
    document_type { build(:document_type_schema, path_prefix: "/prefix").id }
    publication_state { "changes_not_sent_to_draft" }
    review_state { "unreviewed" }
    edition_number { (rand * 100).to_i }
  end
end
