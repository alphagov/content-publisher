# frozen_string_literal: true

FactoryBot.define do
  factory :document do
    content_id { SecureRandom.uuid }
    locale { I18n.available_locales.sample }
    title { SecureRandom.alphanumeric(10) }
    base_path { title ? "/prefix/#{title.parameterize}" : nil }
    document_type_id { build(:document_type, path_prefix: "/prefix").id }
    publication_state { "changes_not_sent_to_draft" }
    review_state { "unreviewed" }
    current_edition_number { (rand * 100).to_i }
    update_type { "major" }

    trait :in_preview do
      publication_state { "sent_to_draft" }
    end

    trait :publishable do
      publication_state { "sent_to_draft" }
      summary { SecureRandom.alphanumeric(10) }
    end

    trait :published do
      has_live_version_on_govuk { true }
      change_note { SecureRandom.alphanumeric(10) }
      summary { SecureRandom.alphanumeric(10) }
      publication_state { "sent_to_live" }
    end

    trait :retired do
      has_live_version_on_govuk { true }
      publication_state { "sent_to_live" }
      live_state { "retired" }
    end
  end
end
