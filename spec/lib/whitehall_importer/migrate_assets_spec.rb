# frozen_string_literal: true

RSpec.describe WhitehallImporter::MigrateAssets do
  describe ".call" do
    it "should take a WhitehallMigration::DocumentImport record as an argument" do
      expect { described_class.call(build(:whitehall_migration_document_import)) }.not_to raise_error
    end
  end
end
