# frozen_string_literal: true

FactoryBot.define do
  factory :image_revision, class: Image::Revision do
    association :image, factory: :image
    association :created_by, factory: :user

    transient do
      filename { SecureRandom.hex(8) }
      width { 1000 }
      height { 1000 }
      crop_x { 0 }
      crop_y { 166 }
      crop_width { 1000 }
      crop_height { 667 }
      fixture { "1000x1000.jpg" }
      assets { nil }
      alt_text { nil }
      caption { nil }
      credit { nil }
    end

    after(:build) do |revision, evaluator|
      unless revision.blob_revision
        revision.blob_revision = evaluator.association(
          :image_blob_revision,
          filename: evaluator.filename,
          width: evaluator.width,
          height: evaluator.height,
          crop_x: evaluator.crop_x,
          crop_y: evaluator.crop_y,
          crop_width: evaluator.crop_width,
          crop_height: evaluator.crop_height,
          fixture: evaluator.fixture,
          assets: evaluator.assets,
        )
      end

      unless revision.metadata_revision
        revision.metadata_revision = evaluator.association(
          :image_metadata_revision,
          alt_text: evaluator.alt_text,
          caption: evaluator.caption,
          credit: evaluator.credit,
        )

      end
    end

    trait :on_asset_manager do
      transient {
        alt_text { SecureRandom.hex(8) }
        state { :draft }
      }

      after(:build) do |revision, evaluator|
        revision.blob_revision = evaluator.association(
          :image_blob_revision,
          :on_asset_manager,
          filename: evaluator.filename,
          width: evaluator.width,
          height: evaluator.height,
          crop_x: evaluator.crop_x,
          crop_y: evaluator.crop_y,
          crop_width: evaluator.crop_width,
          crop_height: evaluator.crop_height,
          fixture: evaluator.fixture,
          assets: evaluator.assets,
          state: evaluator.state,
        )

        revision.metadata_revision = evaluator.association(
          :image_metadata_revision,
          alt_text: evaluator.alt_text,
          caption: evaluator.caption,
          credit: evaluator.credit,
        )
      end
    end
  end
end
