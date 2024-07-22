RSpec.describe WhitehallImporter::MigrateAssets do
  describe ".call" do
    before do
      stub_any_asset_manager_call
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

    it "raises NotImplementedError error" do
      whitehall_import = build(:whitehall_migration_document_import, assets: [asset])
      expect { described_class.call(whitehall_import) }
        .to raise_error(NotImplementedError)
    end
  end
end
