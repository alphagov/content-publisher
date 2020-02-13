FactoryBot.define do
  factory :whitehall_migration_asset_import, class: "WhitehallMigration::AssetImport" do
    document_import { association :whitehall_migration_document_import }
    state { "pending" }

    for_image

    trait :for_image do
      file_attachment_revision { nil }
      image_revision { build(:image_revision, :on_asset_manager, state: :live) }
      original_asset_url { "https://asset-manager.gov.uk/blah/847150/foo.jpg" }
    end

    trait :for_file_attachment do
      image_revision { nil }
      file_attachment_revision { build(:file_attachment_revision, :on_asset_manager, state: :live) }
      original_asset_url { "https://asset-manager.gov.uk/blah/847150/foo.pdf" }
    end
  end
end
