# frozen_string_literal: true

RSpec.describe WhitehallMigration::AssetImport do
  describe ".content_publisher_asset" do
    it "returns the file attachment asset when associated with one" do
      asset = build(:whitehall_migration_asset_import, :for_file_attachment)
      expect(asset.content_publisher_asset).to be_kind_of(FileAttachment::Asset)
    end

    it "returns the 960 image asset when associated with an image" do
      asset = build(:whitehall_migration_asset_import, :for_image)
      expect(asset.content_publisher_asset)
        .to be_kind_of(Image::Asset).and eq(asset.image_revision.asset("960"))
    end

    it "returns the correct sized image when called on a recognised image size" do
      image_300_wide = build(:whitehall_migration_asset_import, :for_image, variant: "s300")
      image_960_wide = build(:whitehall_migration_asset_import, :for_image, variant: "s960")
      expect(image_300_wide.content_publisher_asset)
        .to be_kind_of(Image::Asset).and eq(image_300_wide.image_revision.asset("300"))
      expect(image_960_wide.content_publisher_asset)
        .to be_kind_of(Image::Asset).and eq(image_960_wide.image_revision.asset("960"))
    end

    it "returns nil when called on an unrecognised image size" do
      asset = build(:whitehall_migration_asset_import, :for_image, variant: "s216")
      expect(asset.content_publisher_asset).to be_nil
    end

    it "returns nil when called on a file attachment variant" do
      asset = build(:whitehall_migration_asset_import, :for_file_attachment, variant: "thumbnail")
      expect(asset.content_publisher_asset).to be_nil
    end
  end

  describe ".whitehall_asset_id" do
    it "returns the asset manager ID of the original asset" do
      whitehall_asset_id = "847150"
      asset = build(
        :whitehall_migration_asset_import,
        original_asset_url: "https://asset-manager.gov.uk/blah/#{whitehall_asset_id}/foo.jpg",
      )
      expect(asset.whitehall_asset_id).to eq(whitehall_asset_id)
    end
  end

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
