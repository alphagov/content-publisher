# frozen_string_literal: true

FactoryBot.define do
  factory :image_blob_revision, class: Image::BlobRevision do
    association :created_by, factory: :user

    filename { SecureRandom.hex(8) }
    width { 1000 }
    height { 1000 }
    crop_x { 0 }
    crop_y { 166 }
    crop_width { 1000 }
    crop_height { 667 }

    transient do
      fixture { "1000x1000.jpg" }
      assets { nil }
    end

    after(:build) do |blob_revision, evaluator|
      fixture_path = Rails.root.join("spec/fixtures/files/#{evaluator.fixture}")

      blob_revision.blob = ActiveStorage::Blob.build_after_upload(
        io: File.new(fixture_path),
        filename: blob_revision.filename,
      )

      if evaluator.assets
        blob_revision.assets = evaluator.assets
      else
        blob_revision.ensure_assets
      end
    end

    trait :on_asset_manager do
      transient {
        state { :draft }
      }

      after(:build) do |blob_revision, evaluator|
        blob_revision.assets.each do |asset|
          url = "https://asset-manager.test.gov.uk/media/" +
            "asset-id#{SecureRandom.hex(8)}/#{blob_revision.filename}"
          asset.assign_attributes(state: evaluator.state, file_url: url)
        end
      end
    end
  end
end
