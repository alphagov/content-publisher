# frozen_string_literal: true

RSpec.describe WhitehallImporter::MigrateAssets do
  describe ".call" do
    before { stub_any_asset_manager_call }

    it "should redirect live attachments to their content publisher equivalents" do
      asset = build(:whitehall_migration_asset_import, :for_file_attachment)
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])
      redirect_request = stub_asset_manager_update_asset(
        asset.whitehall_asset_id,
        redirect_url: asset.file_attachment_revision.asset_url,
      )

      described_class.call(whitehall_import)
      expect(redirect_request).to have_been_requested
      expect(asset.state).to eq("redirected")
    end

    it "should redirect live images to their content publisher equivalents" do
      asset = build(:whitehall_migration_asset_import, :for_image)
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])
      redirect_request = stub_asset_manager_update_asset(
        asset.whitehall_asset_id,
        redirect_url: asset.image_revision.asset_url("960"),
      )

      described_class.call(whitehall_import)
      expect(redirect_request).to have_been_requested
      expect(asset.state).to eq("redirected")
    end

    it "should redirect live image variants to their content publisher equivalents" do
      asset = build(:whitehall_migration_asset_import, :for_image, variant: "s300")
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])
      redirect_request = stub_asset_manager_update_asset(
        asset.whitehall_asset_id,
        redirect_url: asset.image_revision.asset_url("300"),
      )

      described_class.call(whitehall_import)
      expect(redirect_request).to have_been_requested
      expect(asset.state).to eq("redirected")
    end
  end
end
