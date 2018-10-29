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
    current_edition_number { (rand * 100).to_i }
    update_type { "major" }

    trait :with_required_content_for_publishing do
      summary { SecureRandom.alphanumeric(10) }
      update_type { "minor" }
    end
  end
end
