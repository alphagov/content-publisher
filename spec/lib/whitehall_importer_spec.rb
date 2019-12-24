# frozen_string_literal: true

RSpec.describe WhitehallImporter do
  describe ".create_migration" do
    let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }
    let(:whitehall_export_page_1) { build(:whitehall_export_index, documents: build_list(:whitehall_export_index_document, 100)) }
    let(:whitehall_export_page_2) { build(:whitehall_export_index, documents: build_list(:whitehall_export_index_document, 10)) }

    before do
      stub_request(:get, "#{whitehall_host}/government/admin/export/document?lead_organisation=123&page_count=100&page_number=1&type=NewsArticle")
        .to_return(status: 200, body: whitehall_export_page_1.to_json)
      stub_request(:get, "#{whitehall_host}/government/admin/export/document?lead_organisation=123&page_count=100&page_number=2&type=NewsArticle")
        .to_return(status: 200, body: whitehall_export_page_2.to_json)
    end

    it "creates a WhitehallMigration" do
      freeze_time do
        expect { WhitehallImporter.create_migration("123", "NewsArticle") }.to change { WhitehallMigration.count }.by(1)
        expect(WhitehallMigration.last.organisation_content_id).to eq("123")
        expect(WhitehallMigration.last.document_type).to eq("NewsArticle")
        expect(WhitehallMigration.last.start_time).to eq(Time.current)
      end
    end

    it "creates a pending WhitehallMigration::DocumentImport for each listed item" do
      expect { WhitehallImporter.create_migration("123", "NewsArticle") }.to change { WhitehallMigration::DocumentImport.count }.by(110)
      expect(WhitehallMigration::DocumentImport.all.pluck(:state).uniq).to eq(%w(pending))
    end
  end

  describe ".import_and_sync" do
    before do
      allow(ResyncService).to receive(:call)
      allow(WhitehallImporter::ClearLinksetLinks).to receive(:call)
    end

    let(:whitehall_export_document) { build(:whitehall_export_document) }

    it "creates and returns a WhitehallMigration::DocumentImport" do
      whitehall_migration_document_import = nil
      expect { whitehall_migration_document_import = WhitehallImporter.import_and_sync(whitehall_export_document) }
        .to change { WhitehallMigration::DocumentImport.count }
        .by(1)
      expect(whitehall_migration_document_import).to be_an_instance_of(WhitehallMigration::DocumentImport)
    end

    it "stores the exported whitehall data" do
      WhitehallImporter.import_and_sync(whitehall_export_document)
      whitehall_migration_document_import = WhitehallMigration::DocumentImport.find_by(whitehall_document_id: whitehall_export_document["id"])
      expect(whitehall_migration_document_import.payload).to eq(whitehall_export_document)
    end

    it "doesn't sync if import fails" do
      allow(WhitehallImporter::Import).to receive(:call)
        .with(whitehall_export_document)
        .and_raise(WhitehallImporter::AbortImportError, "Booo, import failed")

      expect(WhitehallImporter).not_to receive(:sync)
      WhitehallImporter.import_and_sync(whitehall_export_document)
    end
  end

  describe ".import" do
    let(:whitehall_migration_document_import) { create(:whitehall_migration_document_import) }

    it "imports a document" do
      expect(WhitehallImporter::Import).to receive(:call)
      WhitehallImporter.import(whitehall_migration_document_import)
    end

    it "raises if the WhitehallMigration::DocumentImport doesn't have a state of importing" do
      whitehall_migration_document_import = create(:whitehall_migration_document_import, state: "imported")
      expect { WhitehallImporter.import(whitehall_migration_document_import) }
        .to raise_error(RuntimeError, "Cannot import with a state of imported")
    end

    context "when the import is successful" do
      it "marks the import as imported" do
        WhitehallImporter.import(whitehall_migration_document_import)
        expect(whitehall_migration_document_import).to be_imported
      end

      it "sets the timeline entry as Imported from Whitehall" do
        WhitehallImporter.import(whitehall_migration_document_import)
        expect(TimelineEntry.last).to be_imported_from_whitehall
      end
    end

    context "when the import fails" do
      before do
        allow(WhitehallImporter::Import).to receive(:call).and_raise(message)
      end

      let(:message) { "Import failed" }

      it "marks the import as failed and logs the error" do
        WhitehallImporter.import(whitehall_migration_document_import)
        expect(whitehall_migration_document_import).to be_import_failed
        expect(whitehall_migration_document_import.error_log).to eq("#<RuntimeError: #{message}>")
      end
    end

    context "when the import aborts" do
      before do
        allow(WhitehallImporter::Import).to receive(:call).and_raise(
          WhitehallImporter::AbortImportError,
          message,
        )
      end

      let(:message) { "Import aborted" }

      it "marks the import as aborted and logs the error" do
        WhitehallImporter.import(whitehall_migration_document_import)
        expect(whitehall_migration_document_import).to be_import_aborted
        expect(whitehall_migration_document_import.error_log).to eq("#<WhitehallImporter::AbortImportError: #{message}>")
      end
    end
  end

  describe ".sync" do
    before do
      allow(ResyncService).to receive(:call).with(whitehall_migration_document_import.document)
      allow(WhitehallImporter::ClearLinksetLinks).to receive(:call).with(whitehall_migration_document_import.document.content_id)
    end

    let(:whitehall_migration_document_import) { create(:whitehall_migration_document_import, state: "imported") }

    it "syncs the imported document with publishing-api" do
      expect(ResyncService).to receive(:call).with(whitehall_migration_document_import.document)
      expect(WhitehallImporter::ClearLinksetLinks).to receive(:call).with(whitehall_migration_document_import.document.content_id)
      WhitehallImporter.sync(whitehall_migration_document_import)
    end

    it "returns a completed WhitehallMigration::DocumentImport" do
      WhitehallImporter.sync(whitehall_migration_document_import)
      expect(whitehall_migration_document_import).to be_completed
    end

    it "raises if the WhitehallMigration::DocumentImport doesn't have a state of imported" do
      whitehall_migration_document_import = create(:whitehall_migration_document_import, state: "importing")
      expect { WhitehallImporter.sync(whitehall_migration_document_import) }
        .to raise_error(RuntimeError, "Cannot sync with a state of importing")
    end

    context "when the sync fails" do
      before do
        allow(ResyncService).to receive(:call)
          .with(whitehall_migration_document_import.document)
          .and_raise(GdsApi::HTTPTooManyRequests.new(429, message))
      end

      let(:message) { "Ahhh too many requests" }

      it "marks the import as failed due to sync issues and logs the error" do
        WhitehallImporter.sync(whitehall_migration_document_import)

        expect(whitehall_migration_document_import).to be_sync_failed
        expect(whitehall_migration_document_import.error_log).to eq("#<GdsApi::HTTPTooManyRequests: #{message}>")
      end
    end
  end
end
