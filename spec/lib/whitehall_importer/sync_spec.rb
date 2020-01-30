# frozen_string_literal: true

RSpec.describe WhitehallImporter::Sync do
  describe ".call" do
    before do
      allow(ResyncDocumentService).to receive(:call).with(whitehall_document)
      allow(WhitehallImporter::ClearLinksetLinks).to receive(:call)
                                                 .with(whitehall_document.content_id)
    end

    let(:whitehall_migration_document_import) do
      build(:whitehall_migration_document_import, state: "imported")
    end

    let(:whitehall_document) { whitehall_migration_document_import.document }

    it "syncs the imported document with Publishing API" do
      expect(ResyncDocumentService).to receive(:call)
                                   .with(whitehall_document)
      expect(WhitehallImporter::ClearLinksetLinks).to receive(:call)
                                                  .with(whitehall_document.content_id)

      described_class.call(whitehall_migration_document_import)
    end

    it "redirects or deletes the corresponding Whitehall assets" do
      expect(WhitehallImporter::MigrateAssets).to receive(:call)
                                              .with(whitehall_migration_document_import)
      described_class.call(whitehall_migration_document_import)
    end

    it "returns a completed WhitehallMigration::DocumentImport" do
      described_class.call(whitehall_migration_document_import)
      expect(whitehall_migration_document_import).to be_completed
    end

    it "raises if the WhitehallMigration::DocumentImport doesn't have a state of imported" do
      whitehall_migration_document_import = build(:whitehall_migration_document_import)
      expect { described_class.call(whitehall_migration_document_import) }
        .to raise_error(RuntimeError, "Cannot sync with a state of pending")
    end
  end
end
