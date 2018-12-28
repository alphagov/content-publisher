# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_edition, class: Versioned::Edition do
    last_edited_at { Time.zone.now }
    current { true }
    live { false }
    association :created_by, factory: :user
    association :document, factory: :versioned_document

    after(:build) do |edition, evaluator|
      edition.number = edition.document&.next_edition_number unless edition.number
      unless edition.revision
        edition.revision = evaluator.association(
          :versioned_revision,
          created_by: edition.created_by,
          document: edition.document,
        )
      end

      unless edition.status
        edition.status = evaluator.association(
          :versioned_edition_status,
          created_by: edition.created_by,
          revision_at_creation: edition.revision,
        )
      end
    end

    trait :published do
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
