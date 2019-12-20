# frozen_string_literal: true

RSpec.describe WhitehallImporter do
  describe ".import_and_sync" do
    before do
      allow(ResyncService).to receive(:call)
      allow(WhitehallImporter::ClearLinksetLinks).to receive(:call)
    end

    let(:whitehall_export_document) { build(:whitehall_export_document) }

    it "creates and returns a WhitehallImport" do
      whitehall_import = nil
      expect { whitehall_import = WhitehallImporter.import_and_sync(whitehall_export_document) }
        .to change { WhitehallImport.count }
        .by(1)
      expect(whitehall_import).to be_an_instance_of(WhitehallImport)
    end

    it "stores the exported whitehall data" do
      WhitehallImporter.import_and_sync(whitehall_export_document)
      whitehall_import = WhitehallImport.find_by(whitehall_document_id: whitehall_export_document["id"])
      expect(whitehall_import.payload).to eq(whitehall_export_document)
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
    before { allow(WhitehallImporter::Import).to receive(:call) }
    let(:whitehall_import) { create(:whitehall_import) }

    it "imports a document" do
      expect(WhitehallImporter::Import).to receive(:call)
      WhitehallImporter.import(whitehall_import)
    end

    it "raises if the WhitehallImport doesn't have a state of importing" do
      whitehall_import = create(:whitehall_import, state: "imported")
      expect { WhitehallImporter.import(whitehall_import) }
        .to raise_error(RuntimeError, "Cannot import with a state of imported")
    end

    context "when the import is successful" do
      it "marks the import as imported" do
        WhitehallImporter.import(whitehall_import)
        expect(whitehall_import).to be_imported
      end
    end

    context "when the import fails" do
      before do
        allow(WhitehallImporter::Import).to receive(:call).and_raise(message)
      end

      let(:message) { "Import failed" }

      it "marks the import as failed and logs the error" do
        WhitehallImporter.import(whitehall_import)
        expect(whitehall_import).to be_import_failed
        expect(whitehall_import.error_log).to eq("#<RuntimeError: #{message}>")
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
        WhitehallImporter.import(whitehall_import)
        expect(whitehall_import).to be_import_aborted
        expect(whitehall_import.error_log).to eq("#<WhitehallImporter::AbortImportError: #{message}>")
      end
    end
  end

  describe ".sync" do
    before do
      allow(ResyncService).to receive(:call).with(whitehall_import.document)
      allow(WhitehallImporter::ClearLinksetLinks).to receive(:call).with(whitehall_import.document.content_id)
    end

    let(:whitehall_import) { create(:whitehall_import, state: "imported") }

    it "syncs the imported document with publishing-api" do
      expect(ResyncService).to receive(:call).with(whitehall_import.document)
      expect(WhitehallImporter::ClearLinksetLinks).to receive(:call).with(whitehall_import.document.content_id)
      WhitehallImporter.sync(whitehall_import)
    end

    it "returns a completed WhitehallImport" do
      WhitehallImporter.sync(whitehall_import)
      expect(whitehall_import).to be_completed
    end

    it "raises if the WhitehallImport doesn't have a state of imported" do
      whitehall_import = create(:whitehall_import, state: "importing")
      expect { WhitehallImporter.sync(whitehall_import) }
        .to raise_error(RuntimeError, "Cannot sync with a state of importing")
    end

    context "when the sync fails" do
      before do
        allow(ResyncService).to receive(:call)
          .with(whitehall_import.document)
          .and_raise(GdsApi::HTTPTooManyRequests.new(429, message))
      end

      let(:message) { "Ahhh too many requests" }

      it "marks the import as failed due to sync issues and logs the error" do
        WhitehallImporter.sync(whitehall_import)

        expect(whitehall_import).to be_sync_failed
        expect(whitehall_import.error_log).to eq("#<GdsApi::HTTPTooManyRequests: #{message}>")
      end
    end
  end
end
