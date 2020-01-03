# frozen_string_literal: true

RSpec.describe "Import tasks" do
  describe "import:whitehall_migration" do
    let(:whitehall_migration_document_import) { build(:whitehall_migration_document_import) }

    before do
      allow($stdout).to receive(:puts)
      Rake::Task["import:whitehall_migration"].reenable
      stub_publishing_api_has_lookups(
        "/government/organisations/cabinet-office" => "96ae61d6-c2a1-48cb-8e67-da9d105ae381",
      )
      allow(WhitehallImporter).to receive(:create_migration).and_return(whitehall_migration_document_import)
    end

    it "calls WhitehallImport::create_migration with correct arguments" do
      Rake::Task["import:whitehall_migration"].invoke("cabinet-office", "NewsArticle")
      WhitehallImporter.should have_received(:create_migration).with("96ae61d6-c2a1-48cb-8e67-da9d105ae381", "NewsArticle")
    end
  end

  describe "import:whitehall_document" do
    let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }
    let(:whitehall_export) { build(:whitehall_export_document) }
    let(:whitehall_migration_document_import) {
      build(
        :whitehall_migration_document_import,
        whitehall_document_id: "123",
        payload: nil,
        content_id: nil,
        state: "pending",
      )
    }

    before do
      allow($stdout).to receive(:puts)
      Rake::Task["import:whitehall_document"].reenable
      allow(ResyncService).to receive(:call)
      allow(WhitehallImporter::ClearLinksetLinks).to receive(:call)
      stub_request(:get, "#{whitehall_host}/government/admin/export/document/123")
        .to_return(status: 200, body: whitehall_export.to_json)
    end

    it "creates a document" do
      expect { Rake::Task["import:whitehall_document"].invoke("123") }.to change { Document.count }.by(1)
    end

    it "creates a whitehall migration document import" do
      expect { Rake::Task["import:whitehall_document"].invoke("123") }.to change { WhitehallMigration::DocumentImport.count }.by(1)
    end

    it "imports the export and syncs with publishing-api" do
      expect(WhitehallImporter).to receive(:import_and_sync).and_call_original
      Rake::Task["import:whitehall_document"].invoke("123")
    end

    it "aborts if the import fails" do
      expect(WhitehallImporter::Import).to receive(:call).and_raise("Error importing")

      expect($stdout).to receive(:puts).with("Import failed")
      expect($stdout).to receive(:puts).with("Error: #<RuntimeError: Error importing>")
      expect { Rake::Task["import:whitehall_document"].invoke("123") }
        .to raise_error(SystemExit)
    end
  end
end
