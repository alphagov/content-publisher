# frozen_string_literal: true

RSpec.describe WhitehallImporter do
  include ActiveJob::TestHelper
  describe ".create_migration" do
    context "with organisation and type specified" do
      let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }
      let(:whitehall_export_page_1) { build(:whitehall_export_index, documents: build_list(:whitehall_export_index_document, 100)) }
      let(:whitehall_export_page_2) { build(:whitehall_export_index, documents: build_list(:whitehall_export_index_document, 10)) }

      before do
        stub_request(:get, "#{whitehall_host}/government/admin/export/document?lead_organisation=123&page_count=100&page_number=1&type=news_article")
          .to_return(status: 200, body: whitehall_export_page_1.to_json)
        stub_request(:get, "#{whitehall_host}/government/admin/export/document?lead_organisation=123&page_count=100&page_number=2&type=news_article")
          .to_return(status: 200, body: whitehall_export_page_2.to_json)
      end

      it "creates a WhitehallMigration" do
        freeze_time do
          expect { WhitehallImporter.create_migration("123", "news_article") }.to change { WhitehallMigration.count }.by(1)
          expect(WhitehallMigration.last.organisation_content_id).to eq("123")
          expect(WhitehallMigration.last.document_type).to eq("news_article")
          expect(WhitehallMigration.last.document_subtypes).to eq([])
          expect(WhitehallMigration.last.created_at).to eq(Time.current)
        end
      end

      it "creates a pending WhitehallMigration::DocumentImport for each listed item" do
        expect { WhitehallImporter.create_migration("123", "news_article") }.to change { WhitehallMigration::DocumentImport.pending.count }.by(110)
      end

      it "queues a job for each listed document" do
        WhitehallImporter.create_migration("123", "news_article")
        expect(WhitehallDocumentImportJob).to have_been_enqueued.exactly(110).times
      end
    end

    context "with organisation, type and subtype specified" do
      let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }
      let(:whitehall_export_page_1) { build(:whitehall_export_index, documents: build_list(:whitehall_export_index_document, 100)) }
      let(:whitehall_export_page_2) { build(:whitehall_export_index, documents: build_list(:whitehall_export_index_document, 10)) }

      before do
        stub_request(:get, "#{whitehall_host}/government/admin/export/document?lead_organisation=123&page_count=100&page_number=1&type=news_article&subtypes[]=news_story&subtypes[]=press_release")
          .to_return(status: 200, body: whitehall_export_page_1.to_json)
        stub_request(:get, "#{whitehall_host}/government/admin/export/document?lead_organisation=123&page_count=100&page_number=2&type=news_article&subtypes[]=news_story&subtypes[]=press_release")
          .to_return(status: 200, body: whitehall_export_page_2.to_json)
      end

      it "creates a WhitehallMigration" do
        freeze_time do
          expect { WhitehallImporter.create_migration("123", "news_article", %w(press_release news_story)) }.to change { WhitehallMigration.count }.by(1)
          expect(WhitehallMigration.last.organisation_content_id).to eq("123")
          expect(WhitehallMigration.last.document_type).to eq("news_article")
          expect(WhitehallMigration.last.document_subtypes).to eq(%w(press_release news_story))
          expect(WhitehallMigration.last.created_at).to eq(Time.current)
        end
      end

      it "creates a pending WhitehallMigration::DocumentImport for each listed item" do
        expect { WhitehallImporter.create_migration("123", "news_article", %w(press_release news_story)) }.to change { WhitehallMigration::DocumentImport.pending.count }.by(110)
      end

      it "queues a job for each listed document" do
        WhitehallImporter.create_migration("123", "news_article", %w(press_release news_story))
        expect(WhitehallDocumentImportJob).to have_been_enqueued.exactly(110).times
      end
    end
  end

  describe ".import_and_sync" do
    let(:whitehall_export_document) { build(:whitehall_export_document) }
    let(:whitehall_migration_document_import) do
      build(
        :whitehall_migration_document_import,
        whitehall_document_id: "123",
        state: "pending",
      )
    end
    let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }

    before do
      allow(ResyncDocumentService).to receive(:call)
      allow(WhitehallImporter::ClearLinksetLinks).to receive(:call)
      allow(WhitehallImporter::Import).to receive(:call).and_return(build(:document, :with_current_edition))
      stub_request(:get, "#{whitehall_host}/government/admin/export/document/123")
        .to_return(status: 200, body: whitehall_export_document.to_json)
    end

    it "returns a WhitehallMigration::DocumentImport" do
      expect { WhitehallImporter.import_and_sync(whitehall_migration_document_import) }
        .to change { WhitehallMigration::DocumentImport.count }
        .by(1)
      expect(whitehall_migration_document_import).to be_an_instance_of(WhitehallMigration::DocumentImport)
    end

    it "stores the exported whitehall data" do
      document_import = WhitehallImporter.import_and_sync(whitehall_migration_document_import)
      expect(document_import.payload).to eq(whitehall_export_document)
    end

    it "raises if the WhitehallMigration::DocumentImport doesn't have a state of pending" do
      whitehall_migration_document_import = create(:whitehall_migration_document_import, state: "imported")
      expect { WhitehallImporter.import_and_sync(whitehall_migration_document_import) }
        .to raise_error(RuntimeError, "Cannot import with a state of imported")
    end
  end

  describe ".import" do
    let(:whitehall_migration_document_import) { create(:whitehall_migration_document_import) }

    it "imports a document" do
      expect(WhitehallImporter::Import).to receive(:call)
      WhitehallImporter.import(whitehall_migration_document_import)
    end

    it "raises if the WhitehallMigration::DocumentImport doesn't have a state of pending" do
      whitehall_migration_document_import = create(:whitehall_migration_document_import, state: "imported")
      expect { WhitehallImporter.import(whitehall_migration_document_import) }
        .to raise_error(RuntimeError, "Cannot import with a state of imported")
    end

    context "when the integrity check fails" do
      let(:problems) { ["foo failed"] }
      let(:payload) { { "foo" => "bar" } }
      let(:integrity_check) do
        instance_double(
          WhitehallImporter::IntegrityChecker,
          valid?: false,
          problems: problems,
          proposed_payload: payload,
          edition: build(:edition),
        )
      end

      before do
        allow(WhitehallImporter::Import).to receive(:call).and_raise(
          WhitehallImporter::IntegrityCheckError.new(integrity_check),
        )
      end

      it "marks the import as aborted and logs the error and the payload" do
        WhitehallImporter.import(whitehall_migration_document_import)

        expect(whitehall_migration_document_import).to be_import_aborted
        expect(whitehall_migration_document_import.integrity_check_problems).to eq(problems)
        expect(whitehall_migration_document_import.integrity_check_proposed_payload).to eq(payload)
      end
    end
  end

  describe ".sync" do
    before do
      allow(ResyncDocumentService).to receive(:call).with(whitehall_migration_document_import.document)
      allow(WhitehallImporter::ClearLinksetLinks).to receive(:call).with(whitehall_migration_document_import.document.content_id)
    end

    let(:whitehall_migration_document_import) { create(:whitehall_migration_document_import, state: "imported") }

    it "syncs the imported document with publishing-api" do
      expect(ResyncDocumentService).to receive(:call).with(whitehall_migration_document_import.document)
      expect(WhitehallImporter::ClearLinksetLinks).to receive(:call).with(whitehall_migration_document_import.document.content_id)
      WhitehallImporter.sync(whitehall_migration_document_import)
    end

    it "redirects or deletes the corresponding Whitehall assets" do
      expect(WhitehallImporter::MigrateAssets).to receive(:call).with(whitehall_migration_document_import)
      WhitehallImporter.sync(whitehall_migration_document_import)
    end

    it "returns a completed WhitehallMigration::DocumentImport" do
      WhitehallImporter.sync(whitehall_migration_document_import)
      expect(whitehall_migration_document_import).to be_completed
    end

    it "raises if the WhitehallMigration::DocumentImport doesn't have a state of imported" do
      whitehall_migration_document_import = create(:whitehall_migration_document_import, state: "pending")
      expect { WhitehallImporter.sync(whitehall_migration_document_import) }
        .to raise_error(RuntimeError, "Cannot sync with a state of pending")
    end
  end
end
