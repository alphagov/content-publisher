# frozen_string_literal: true

FactoryBot.define do
  factory :file_attachment_revision, class: FileAttachment::Revision do
    association :file_attachment, factory: :file_attachment
    association :created_by, factory: :user

    transient do
      filename { SecureRandom.hex(8) }
      fixture { "text-file.txt" }
      title { SecureRandom.hex(8) }
    end

    after(:build) do |revision, evaluator|
      unless revision.file_revision
        revision.file_revision = evaluator.association(
          :file_attachment_file_revision,
          filename: evaluator.filename,
          fixture: evaluator.fixture,
        )
      end

      unless revision.metadata_revision
        revision.metadata_revision = evaluator.association(
          :file_attachment_metadata_revision,
          title: evaluator.title,
        )
      end
    end

    trait :on_asset_manager do
      transient {
        state { :draft }
      }

      after(:build) do |revision, evaluator|
        revision.file_revision = evaluator.association(
          :file_attachment_file_revision,
          :on_asset_manager,
          filename: evaluator.filename,
          fixture: evaluator.fixture,
          state: evaluator.state,
        )

        revision.metadata_revision = evaluator.association(
          :file_attachment_metadata_revision,
          title: evaluator.title,
        )
      end
    end
  end
end
