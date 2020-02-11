RSpec.describe WhitehallImporter::Sync do
  describe ".call" do
    before do
      allow(ResyncDocumentService).to receive(:call).with(whitehall_document)
      allow(WhitehallImporter::ClearLinksetLinks).to receive(:call)
                                                 .with(whitehall_document.content_id)
      stub_whitehall_document_migrated(
        whitehall_migration_document_import.whitehall_document_id,
      )
    end

    let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }

    let(:whitehall_migration_document_import) do
      build(:whitehall_migration_document_import, state: "imported")
    end

    let(:whitehall_document) { whitehall_migration_document_import.document }

    it "syncs the imported document with Publishing API" do
      expect(ResyncDocumentService).to receive(:call)
                                   .with(whitehall_document)
      expect(WhitehallImporter::ClearLinksetLinks).to receive(:call)
                                                  .with(whitehall_document.content_id)

      WhitehallImporter::Sync.call(whitehall_migration_document_import)
    end

    it "marks the document as migrated in Whitehall" do
      request = stub_whitehall_document_migrated(
        whitehall_migration_document_import.whitehall_document_id,
      )

      WhitehallImporter::Sync.call(whitehall_migration_document_import)
      expect(request).to have_been_requested
    end

    it "redirects or deletes the corresponding Whitehall assets" do
      expect(WhitehallImporter::MigrateAssets).to receive(:call)
                                              .with(whitehall_migration_document_import)
      WhitehallImporter::Sync.call(whitehall_migration_document_import)
    end

    it "returns a completed WhitehallMigration::DocumentImport" do
      WhitehallImporter::Sync.call(whitehall_migration_document_import)
      expect(whitehall_migration_document_import).to be_completed
    end

    it "raises if the WhitehallMigration::DocumentImport doesn't have a state of imported" do
      whitehall_migration_document_import = build(:whitehall_migration_document_import)
      expect { WhitehallImporter::Sync.call(whitehall_migration_document_import) }
        .to raise_error(RuntimeError, "Cannot sync with a state of pending")
    end
  end

  def stub_whitehall_document_migrated(document_id)
    stub_request(:post, "#{whitehall_host}/government/admin/export/document/#{document_id}/migrated")
  end
end
