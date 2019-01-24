# frozen_string_literal: true

FactoryBot.define do
  factory :edition do
    last_edited_at { Time.current }
    current { true }
    live { false }
    revision_synced { true }
    association :created_by, factory: :user

    transient do
      content_id { SecureRandom.uuid }
      locale { I18n.available_locales.sample }
      document_type_id { build(:document_type, path_prefix: "/prefix").id }
      title { SecureRandom.alphanumeric(10) }
      update_type { "major" }
      change_note { "First published." }
      summary { nil }
      base_path { title ? "/prefix/#{title.parameterize}" : nil }
      contents { {} }
      tags { {} }
      state { "draft" }
      lead_image_revision { nil }
      image_revisions { [] }
    end

    after(:build) do |edition, evaluator|
      unless edition.document
        edition.document = evaluator.association(
          :document,
          created_by: edition.created_by,
          content_id: evaluator.content_id,
          locale: evaluator.locale,
          document_type_id: evaluator.document_type_id,
        )
      end

      edition.number = edition.document&.next_edition_number unless edition.number

      unless edition.revision
        image_revisions = if evaluator.image_revisions.any?
                            evaluator.image_revisions
                          else
                            [evaluator.lead_image_revision].compact
                          end

        edition.revision = evaluator.association(
          :revision,
          created_by: edition.created_by,
          document: edition.document,
          title: evaluator.title,
          summary: evaluator.summary,
          base_path: evaluator.base_path,
          contents: evaluator.contents,
          tags: evaluator.tags,
          update_type: evaluator.update_type,
          change_note: evaluator.change_note,
          lead_image_revision: evaluator.lead_image_revision,
          image_revisions: image_revisions,
        )
      end

      unless edition.status
        edition.status = evaluator.association(
          :status,
          created_by: edition.created_by,
          revision_at_creation: edition.revision,
          state: evaluator.state,
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
          :status,
          created_by: edition.created_by,
          state: :published,
          revision_at_creation: edition.revision,
        )
      end
    end
  end
end
