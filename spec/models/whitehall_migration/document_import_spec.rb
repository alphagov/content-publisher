# frozen_string_literal: true

RSpec.describe WhitehallMigration::DocumentImport do
  describe ".migratable_assets" do
    it "should return assets that are 'pending' or 'migration_failed'" do
      assets_to_be_processed = [
        create(:whitehall_migration_asset_import, state: "pending"),
        create(:whitehall_migration_asset_import, state: "migration_failed"),
      ]
      assets_to_be_ignored = [
        create(:whitehall_migration_asset_import, state: "redirected"),
        create(:whitehall_migration_asset_import, state: "removed"),
      ]
      document_import = build(:whitehall_migration_document_import,
                              assets: assets_to_be_processed + assets_to_be_ignored)
      expect(document_import.migratable_assets).to eq(assets_to_be_processed)
    end
  end
end
