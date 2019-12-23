# frozen_string_literal: true

FactoryBot.define do
  factory :whitehall_imported_asset do
    original_asset_url { "https://asset-manager.gov.uk/blah/847150/foo.jpg" }
    whitehall_import { build(:whitehall_import) }
    state { "not_processed" }

    trait :image do
      image_revision { build(:image_revision) }
      variants do
        {
          "s300": "https://asset-manager.gov.uk/blah/847151/s300_foo.jpg",
          "s960": "https://asset-manager.gov.uk/blah/847152/s960_foo.jpg",
        }
      end
    end

    trait :file_attachment do
      file_attachment_revision { build(:file_attachment_revision) }
      original_asset_url { "https://asset-manager.gov.uk/blah/847150/foo.pdf" }
      variants do
        {
          "thumbnail": "https://asset-manager.gov.uk/blah/847151/thumbnail_foo.jpg",
        }
      end
    end

    trait :file_attachment do
      file_attachment_revision { build(:file_attachment_revision) }
    end
  end
end