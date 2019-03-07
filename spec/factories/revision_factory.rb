# frozen_string_literal: true

FactoryBot.define do
  trait :revision_fields do
    transient do
      title { SecureRandom.alphanumeric(10) }
      base_path { title ? "/prefix/#{title.parameterize}" : nil }
      summary { nil }
      contents { {} }
      tags { {} }
      update_type { "major" }
      change_note { "First published." }
      scheduled_publishing_datetime { nil }
    end
  end

  factory :revision do
    association :created_by, factory: :user
    document
    association :lead_image_revision, factory: :image_revision
    image_revisions { lead_image_revision ? [lead_image_revision] : [] }

    revision_fields

    after(:build) do |revision, evaluator|
      revision.number = revision.document&.next_revision_number unless revision.number

      unless revision.content_revision
        revision.content_revision = evaluator.association(
          :content_revision,
          title: evaluator.title,
          base_path: evaluator.base_path,
          summary: evaluator.summary,
          contents: evaluator.contents,
          created_by: revision.created_by,
        )
      end

      unless revision.metadata_revision
        revision.metadata_revision = evaluator.association(
          :metadata_revision,
          update_type: evaluator.update_type,
          change_note: evaluator.change_note,
          created_by: revision.created_by,
          scheduled_publishing_datetime: evaluator.scheduled_publishing_datetime,
        )
      end

      unless revision.tags_revision
        revision.tags_revision = evaluator.association(
          :tags_revision,
          tags: evaluator.tags,
          created_by: revision.created_by,
        )
      end
    end
  end
end
