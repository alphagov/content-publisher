# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_revision, class: Versioned::Revision do
    association :created_by, factory: :user
    association :document, factory: :versioned_document

    transient do
      title { SecureRandom.alphanumeric(10) }
      base_path { title ? "/prefix/#{title.parameterize}" : nil }
      summary { nil }
      contents { {} }
      tags { {} }
      update_type { "major" }
      change_note { "First published." }
    end

    after(:build) do |edition, evaluator|
      unless edition.content_revision
        edition.content_revision = evaluator.association(
          :versioned_content_revision,
          title: evaluator.title,
          base_path: evaluator.base_path,
          summary: evaluator.summary,
          contents: evaluator.contents,
          created_by: edition.created_by,
        )
      end

      unless edition.update_revision
        edition.update_revision = evaluator.association(
          :versioned_update_revision,
          update_type: evaluator.update_type,
          change_note: evaluator.change_note,
          created_by: edition.created_by,
        )
      end

      unless edition.tags_revision
        edition.tags_revision = evaluator.association(
          :versioned_tags_revision,
          tags: evaluator.tags,
          created_by: edition.created_by,
        )
      end
    end
  end
end
