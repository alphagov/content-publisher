# frozen_string_literal: true

FactoryBot.define do
  factory :file_attachment_file_revision, class: FileAttachment::FileRevision do
    association :created_by, factory: :user

    filename { SecureRandom.hex(8) }

    transient do
      fixture { "text-file.txt" }
      assets { nil }
    end

    after(:build) do |file_revision, evaluator|
      fixture_path = Rails.root.join("spec/fixtures/files/#{evaluator.fixture}")

      file_revision.blob = ActiveStorage::Blob.build_after_upload(
        io: File.new(fixture_path),
        filename: file_revision.filename,
      )
      file_revision.size = File.size(fixture_path) unless file_revision.size

      if evaluator.assets
        file_revision.assets = evaluator.assets
      else
        file_revision.ensure_assets
      end
    end

    trait :on_asset_manager do
      transient do
        state { :draft }
      end

      after(:build) do |file_revision, evaluator|
        file_revision.assets.each do |asset|
          url = "https://asset-manager.test.gov.uk/media/" +
            "asset-id#{SecureRandom.hex(8)}/#{file_revision.filename}"
          asset.assign_attributes(state: evaluator.state, file_url: url)
        end
      end
    end
  end
end
