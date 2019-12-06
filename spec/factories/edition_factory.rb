# frozen_string_literal: true

FactoryBot.define do
  factory :edition do
    last_edited_at { Time.current }
    current { true }
    live { false }
    revision_synced { true }
    association :created_by, factory: :user

    revision_fields

    transient do
      content_id { SecureRandom.uuid }
      locale { I18n.available_locales.sample }
      document_type_id { build(:document_type, path_prefix: "/prefix").id }
      state { "draft" }
      lead_image_revision { nil }
      image_revisions { [] }
      file_attachment_revisions { [] }
      first_published_at { nil }
    end

    after(:build) do |edition, evaluator|
      unless edition.document
        edition.document = evaluator.association(
          :document,
          created_by: edition.created_by,
          content_id: evaluator.content_id,
          locale: evaluator.locale,
          first_published_at: evaluator.first_published_at,
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
          document_type_id: evaluator.document_type_id,
          title: evaluator.title,
          summary: evaluator.summary,
          base_path: evaluator.base_path,
          contents: evaluator.contents,
          tags: evaluator.tags,
          update_type: evaluator.update_type,
          change_note: evaluator.change_note,
          proposed_publish_time: evaluator.proposed_publish_time,
          backdated_to: evaluator.backdated_to,
          editor_political: evaluator.editor_political,
          lead_image_revision: evaluator.lead_image_revision,
          image_revisions: image_revisions,
          file_attachment_revisions: evaluator.file_attachment_revisions,
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
      first_published_at { Time.current }

      transient do
        state { "published" }
        published_at { Time.current }
      end

      after(:build) do |edition, evaluator|
        edition.status = evaluator.association(
          :status,
          created_by: edition.created_by,
          state: evaluator.state,
          revision_at_creation: edition.revision,
          created_at: evaluator.published_at,
        )
      end
    end

    trait :withdrawn do
      summary { SecureRandom.alphanumeric(10) }
      live { true }
      first_published_at { Time.current }

      transient do
        withdrawal { nil }
      end

      after(:build) do |edition, evaluator|
        edition.status = evaluator.association(
          :status,
          :withdrawn,
          created_by: edition.created_by,
          state: :withdrawn,
          revision_at_creation: edition.revision,
          withdrawal: evaluator.withdrawal,
        )
      end
    end

    trait :removed do
      live { true }

      transient do
        removal { nil }
      end

      after(:build) do |edition, evaluator|
        edition.status = evaluator.association(
          :status,
          :removed,
          created_by: edition.created_by,
          revision_at_creation: edition.revision,
          removal: evaluator.removal,
        )
      end
    end

    trait :schedulable do
      publishable
      proposed_publish_time { Time.current.advance(days: 2) }
    end

    trait :scheduled do
      summary { SecureRandom.alphanumeric(10) }

      transient do
        scheduling { nil }
        publish_time { Time.current.advance(days: 2) }
      end

      after(:build) do |edition, evaluator|
        edition.status = evaluator.association(
          :status,
          :scheduled,
          created_by: edition.created_by,
          state: :scheduled,
          revision_at_creation: edition.revision,
          scheduling: evaluator.scheduling,
          publish_time: evaluator.publish_time,
        )
      end
    end

    trait :failed_to_publish do
      summary { SecureRandom.alphanumeric(10) }

      transient do
        scheduling { nil }
      end

      after(:build) do |edition, evaluator|
        edition.status = evaluator.association(
          :status,
          :failed_to_publish,
          created_by: edition.created_by,
          revision_at_creation: edition.revision,
          scheduling: evaluator.scheduling,
        )
      end
    end

    trait :access_limited do
      transient do
        limit_type { :tagged_organisations }
      end

      after(:build) do |edition, evaluator|
        edition.access_limit = evaluator.association(
          :access_limit,
          limit_type: evaluator.limit_type,
          edition: edition,
          created_by: edition.created_by,
          revision_at_creation: edition.revision,
        )
      end
    end

    trait :political do
      system_political { true }
    end

    trait :not_political do
      system_political { false }
    end

    trait :current_government do
      government_id { Government.current.content_id }
    end

    trait :past_government do
      government_id { Government.past.first.content_id }
    end
  end
end
