# frozen_string_literal: true

RSpec.describe WhitehallMigration::AssetImport do
  describe ".associated_with_only_image_or_file_attachment" do
    it "raises a validation error if associated with an image and a file attachment" do
      illegal_params = {
        file_attachment_revision: build(:file_attachment_revision),
        image_revision: build(:image_revision),
      }
      expect { create(:whitehall_migration_asset_import, illegal_params) }
        .to raise_error(
          ActiveRecord::RecordInvalid,
          "Validation failed: Cannot be associated with both image revision AND file attachment revision",
        )
    end
  end
end
