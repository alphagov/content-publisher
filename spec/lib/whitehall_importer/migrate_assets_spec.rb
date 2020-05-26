RSpec.describe WhitehallImporter::MigrateAssets do
  describe ".call" do
    before do
      stub_any_asset_manager_call
      stub_asset_manager_has_a_whitehall_asset(asset.legacy_url_path, asset_manager_response)
    end

    let(:asset_manager_response) do
      { "id" => "https://asset-manager.dev.gov.uk/assets/#{asset_id}" }
    end
    let(:asset_id) { "847150" }
    let(:asset) { build(:whitehall_migration_asset_import) }

    it "skips migrating any assets that have already been processed" do
      asset = build(:whitehall_migration_asset_import, state: "removed")
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])
      expect(asset).not_to receive(:update!)
      asset_manager_call = stub_any_asset_manager_call
      described_class.call(whitehall_import)
      expect(asset_manager_call).not_to have_been_requested
    end

    it "logs individual errors and put asset into a migration failed state" do
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])
      allow(asset).to receive(:legacy_url_path).and_raise("Some error")
      expect { described_class.call(whitehall_import) }
        .to raise_error "Failed migrating at least one Whitehall asset"
      expect(asset.state).to eq("migration_failed")
      expect(asset.error_message).to include("Some error")
    end

    it "attempts to migrate all assets and raise error only at the end" do
      bad_asset = build(:whitehall_migration_asset_import)
      allow(bad_asset).to receive(:legacy_url_path).and_raise
      whitehall_import = build(:whitehall_migration_document_import, assets: [bad_asset, asset])

      expect { described_class.call(whitehall_import) }
        .to raise_error "Failed migrating at least one Whitehall asset"
      expect(bad_asset.state).to eq("migration_failed")
      expect(asset.state).not_to eq("migration_failed")
    end

    it "deletes draft assets" do
      image_revision = build(:image_revision, :on_asset_manager, state: :draft)
      asset = create(:whitehall_migration_asset_import,
                     image_revision: image_revision)
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])
      delete_asset_request = stub_asset_manager_delete_asset(asset_id)

      described_class.call(whitehall_import)
      expect(delete_asset_request).to have_been_requested
      expect(asset.state).to eq("removed")
    end

    it "deletes draft asset variants" do
      image_revision = build(:image_revision, :on_asset_manager, state: :draft)
      asset = create(:whitehall_migration_asset_import,
                     image_revision: image_revision,
                     variant: "s300")
      delete_asset_request = stub_asset_manager_delete_asset(asset_id)
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])

      described_class.call(whitehall_import)
      expect(delete_asset_request).to have_been_requested
      expect(asset.state).to eq("removed")
    end

    it "redirects live attachments to their content publisher equivalents" do
      asset = build(:whitehall_migration_asset_import, :for_file_attachment)
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])

      stub_asset_manager_has_a_whitehall_asset(
        asset.legacy_url_path, asset_manager_response
      )
      redirect_request = stub_asset_manager_update_asset(
        asset_id,
        redirect_url: asset.file_attachment_revision.asset_url,
      )

      described_class.call(whitehall_import)
      expect(redirect_request).to have_been_requested
      expect(asset.state).to eq("redirected")
    end

    it "deletes attachment variants even if they are live" do
      asset = create(:whitehall_migration_asset_import,
                     :for_file_attachment,
                     variant: "thumbnail")
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])

      stub_asset_manager_has_a_whitehall_asset(
        asset.legacy_url_path, asset_manager_response
      )
      delete_request = stub_asset_manager_delete_asset(asset_id)

      described_class.call(whitehall_import)
      expect(delete_request).to have_been_requested
      expect(asset.state).to eq("removed")
    end

    it "redirects live images to their content publisher equivalents" do
      asset = build(:whitehall_migration_asset_import,
                    :for_image)
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])
      redirect_request = stub_asset_manager_update_asset(
        asset_id,
        redirect_url: asset.image_revision.asset_url("960"),
      )

      described_class.call(whitehall_import)
      expect(redirect_request).to have_been_requested
      expect(asset.state).to eq("redirected")
    end

    it "redirects live image variants to their content publisher equivalents" do
      asset = build(:whitehall_migration_asset_import,
                    :for_image,
                    variant: "s300")
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])
      redirect_request = stub_asset_manager_update_asset(
        asset_id,
        redirect_url: asset.image_revision.asset_url("300"),
      )

      described_class.call(whitehall_import)
      expect(redirect_request).to have_been_requested
      expect(asset.state).to eq("redirected")
    end

    it "deletes live image variants that have no content publisher equivalent" do
      asset = build(:whitehall_migration_asset_import,
                    :for_image,
                    variant: "s216")
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])
      delete_request = stub_asset_manager_delete_asset(asset_id)

      described_class.call(whitehall_import)
      expect(delete_request).to have_been_requested
      expect(asset.state).to eq("removed")
    end
  end
end
