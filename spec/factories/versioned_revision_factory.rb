# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_revision, class: Versioned::Revision do
    association :created_by, factory: :user
    association :document, factory: :versioned_document
    association :lead_image_revision, factory: :versioned_image_revision
    image_revisions { lead_image_revision ? [lead_image_revision] : [] }

    transient do
      title { SecureRandom.alphanumeric(10) }
      base_path { title ? "/prefix/#{title.parameterize}" : nil }
      summary { nil }
      contents { {} }
      tags { {} }
      update_type { "major" }
      change_note { "First published." }
    end

    after(:build) do |revision, evaluator|
      revision.number = revision.document&.next_revision_number unless revision.number

      unless revision.content_revision
        revision.content_revision = evaluator.association(
          :versioned_content_revision,
          title: evaluator.title,
          base_path: evaluator.base_path,
          summary: evaluator.summary,
          contents: evaluator.contents,
          created_by: revision.created_by,
        )
      end

      unless revision.update_revision
        revision.update_revision = evaluator.association(
          :versioned_update_revision,
          update_type: evaluator.update_type,
          change_note: evaluator.change_note,
          created_by: revision.created_by,
        )
      end

      unless revision.tags_revision
        revision.tags_revision = evaluator.association(
          :versioned_tags_revision,
          tags: evaluator.tags,
          created_by: revision.created_by,
        )
      end
    end
  end
end
