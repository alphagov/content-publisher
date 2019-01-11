# frozen_string_literal: true

FactoryBot.define do
  factory :versioned_image_revision, class: Versioned::ImageRevision do
    association :image, factory: :versioned_image
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
      asset_manager_variants { nil }
    end

    after(:build) do |image_revision, evaluator|
      fixture_path = Rails.root.join("spec/fixtures/files/#{evaluator.fixture}")

      image_revision.blob = ActiveStorage::Blob.build_after_upload(
        io: File.new(fixture_path),
        filename: image_revision.filename,
      )

      if evaluator.asset_manager_variants
        image_revision.asset_manager_variants = evaluator.asset_manager_variants
      else
        image_revision.ensure_asset_manager_variants
      end
    end

    trait :on_asset_manager do
      alt_text { SecureRandom.hex(8) }

      transient {
        state { :draft }
      }

      after(:build) do |image_revision, evaluator|
        image_revision.asset_manager_variants.each do |variant|
          url = "https://asset-manager.test.gov.uk/media/" +
            "asset-id#{SecureRandom.hex(8)}/#{image_revision.filename}"
          variant.file.assign_attributes(state: evaluator.state, file_url: url)
        end
      end
    end
  end
end
