# frozen_string_literal: true

RSpec.describe WhitehallImporter::MigrateAssets do
  describe ".call" do
    before { stub_any_asset_manager_call }

    it "should delete draft assets" do
      image_revision = build(:image_revision, :on_asset_manager, state: :draft)
      asset = create(:whitehall_migration_asset_import, image_revision: image_revision)
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])
      delete_asset_request = stub_asset_manager_delete_asset(asset.whitehall_asset_id)

      described_class.call(whitehall_import)
      expect(delete_asset_request).to have_been_requested
      expect(asset.state).to eq("removed")
    end

    it "should delete draft asset variants" do
      image_revision = build(:image_revision, :on_asset_manager, state: :draft)
      asset = create(:whitehall_migration_asset_import,
                     image_revision: image_revision,
                     variant: "s300")
      delete_asset_request = stub_asset_manager_delete_asset(asset.whitehall_asset_id)
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])

      described_class.call(whitehall_import)
      expect(delete_asset_request).to have_been_requested
      expect(asset.state).to eq("removed")
    end

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

    it "should delete attachment variants even if they are live" do
      asset = create(:whitehall_migration_asset_import,
                     :for_file_attachment,
                     variant: "thumbnail")
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])
      delete_request = stub_asset_manager_delete_asset(asset.whitehall_asset_id)

      described_class.call(whitehall_import)
      expect(delete_request).to have_been_requested
      expect(asset.state).to eq("removed")
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

    it "should delete live image variants that have no content publisher equivalent" do
      asset = build(:whitehall_migration_asset_import, :for_image, variant: "s216")
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])
      delete_request = stub_asset_manager_delete_asset(asset.whitehall_asset_id)

      described_class.call(whitehall_import)
      expect(delete_request).to have_been_requested
      expect(asset.state).to eq("removed")
    end
  end
end
