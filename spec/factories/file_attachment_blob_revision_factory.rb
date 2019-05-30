# frozen_string_literal: true

FactoryBot.define do
  factory :file_attachment_blob_revision, class: FileAttachment::BlobRevision do
    association :created_by, factory: :user

    filename { SecureRandom.hex(8) }

    transient do
      fixture { "text-file.txt" }
      asset { nil }
    end

    after(:build) do |blob_revision, evaluator|
      fixture_path = Rails.root.join("spec/fixtures/files/#{evaluator.fixture}")

      blob_revision.blob = ActiveStorage::Blob.build_after_upload(
        io: File.new(fixture_path),
        filename: blob_revision.filename,
      )

      blob_revision.asset = FileAttachment::Asset.new unless blob_revision.asset
    end

    trait :on_asset_manager do
      transient do
        state { :draft }
      end

      after(:build) do |blob_revision, evaluator|
        url = "https://asset-manager.test.gov.uk/media/" +
          "asset-id#{SecureRandom.hex(8)}/#{blob_revision.filename}"
        blob_revision.asset.assign_attributes(state: evaluator.state, file_url: url)
      end
    end
  end
end
