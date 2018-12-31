# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_edition, class: Versioned::Edition do
    last_edited_at { Time.zone.now }
    current { true }
    live { false }
    association :created_by, factory: :user

    transient do
      content_id { SecureRandom.uuid }
      locale { I18n.available_locales.sample }
      document_type_id { build(:document_type, path_prefix: "/prefix").id }
      title { SecureRandom.alphanumeric(10) }
      update_type { "major" }
      change_note { nil }
      summary { nil }
      base_path { title ? "/prefix/#{title.parameterize}" : nil }
      contents { {} }
      tags { {} }
      user_facing_state { "draft" }
    end

    after(:build) do |edition, evaluator|
      unless edition.document
        edition.document = evaluator.association(
          :versioned_document,
          created_by: edition.created_by,
          content_id: evaluator.content_id,
          locale: evaluator.locale,
          document_type_id: evaluator.document_type_id,
          last_edited_at: edition.last_edited_at,
        )
      end

      edition.number = edition.document&.next_edition_number unless edition.number

      unless edition.revision
        edition.revision = evaluator.association(
          :versioned_revision,
          created_by: edition.created_by,
          document: edition.document,
          title: evaluator.title,
          summary: evaluator.summary,
          base_path: evaluator.base_path,
          contents: evaluator.contents,
          tags: evaluator.tags,
          update_type: evaluator.update_type,
          change_note: evaluator.change_note,
        )
      end

      unless edition.status
        edition.status = evaluator.association(
          :versioned_edition_status,
          created_by: edition.created_by,
          revision_at_creation: edition.revision,
          user_facing_state: evaluator.user_facing_state,
        )
      end
    end

    trait :publishable do
      summary { SecureRandom.alphanumeric(10) }
    end

    trait :published do
      summary { SecureRandom.alphanumeric(10) }
      live { true }

      after(:build) do |edition, evaluator|
        edition.status = evaluator.association(
          :versioned_edition_status,
          created_by: edition.created_by,
          user_facing_state: :published,
          revision_at_creation: edition.revision,
        )
      end
    end
  end
end
