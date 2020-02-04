# frozen_string_literal: true

RSpec.describe "Import tasks" do
  describe "import:whitehall_migration" do
    let(:whitehall_migration_document_import) { build(:whitehall_migration_document_import) }

    before(:each) do
      allow($stdout).to receive(:puts)
      Rake::Task["import:whitehall_migration"].reenable
      stub_publishing_api_has_lookups(
        "/government/organisations/cabinet-office" => "96ae61d6-c2a1-48cb-8e67-da9d105ae381",
      )
      allow(WhitehallImporter::CreateMigration).to receive(:call)
                                               .and_return(whitehall_migration_document_import)
    end

    it "calls WhitehallImporter::create_migration with correct arguments when subtype is specified" do
      Rake::Task["import:whitehall_migration"].invoke("cabinet-office", "news_article", "press_release")
      expect(WhitehallImporter::CreateMigration).to have_received(:call)
                                                .with("96ae61d6-c2a1-48cb-8e67-da9d105ae381",
                                                      "news_article",
                                                      %w(press_release))
    end

    it "calls WhitehallImporter::create_migration with correct arguments when no subtype is specified" do
      Rake::Task["import:whitehall_migration"].invoke("cabinet-office", "news_article")
      expect(WhitehallImporter::CreateMigration).to have_received(:call)
                                                .with("96ae61d6-c2a1-48cb-8e67-da9d105ae381",
                                                      "news_article",
                                                      [])
    end
  end

  describe "import:whitehall_document" do
    let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }
    let(:whitehall_export) { build(:whitehall_export_document) }

    let(:pending_document_import) do
      build(:whitehall_migration_document_import)
    end

    let(:integrity_check) do
      instance_double(
        WhitehallImporter::IntegrityChecker,
        valid?: false,
        problems: ["foo failed"],
        proposed_payload: { "foo" => "bar" },
        edition: build(:edition),
      )
    end

    before(:each) do
      Rake::Task["import:whitehall_document"].reenable
      allow($stdout).to receive(:puts)
      allow(WhitehallMigration::DocumentImport).to receive(:create!)
      .and_return(pending_document_import)
    end

    it "imports the export and syncs with publishing-api" do
      imported_document_import =
        build(:whitehall_migration_document_import, state: "imported")
      completed_document_import =
        build(:whitehall_migration_document_import, state: "completed")

      allow(WhitehallImporter::Import).to receive(:call)
        .and_return(imported_document_import)
      allow(WhitehallImporter::Sync).to receive(:call)
        .and_return(completed_document_import)

      expect(WhitehallImporter::Import).to receive(:call)
                                       .with(pending_document_import)
      expect(WhitehallImporter::Sync).to receive(:call)
                                     .with(imported_document_import)

      Rake::Task["import:whitehall_document"].invoke("123")
    end

    it "aborts if an IntegrityCheckError is raised" do
      error = WhitehallImporter::IntegrityCheckError.new(integrity_check)
      allow(WhitehallImporter::Import).to receive(:call)
                                      .and_raise(error)

      expect($stdout).to receive(:puts).with("Import aborted")
      expect($stdout).to receive(:puts).with("Error: #{error.inspect}")
      expect { Rake::Task["import:whitehall_document"].invoke("123") }
        .to raise_error(SystemExit)
    end

    it "aborts if an AbortImportError is raised" do
      error = WhitehallImporter::AbortImportError.new("Aborted")
      allow(WhitehallImporter::Import).to receive(:call)
                                      .and_raise(error)

      expect($stdout).to receive(:puts).with("Import aborted")
      expect($stdout).to receive(:puts).with("Error: #{error.inspect}")
      expect { Rake::Task["import:whitehall_document"].invoke("123") }
        .to raise_error(SystemExit)
    end

    it "aborts if a StandardError exception is raised" do
      error = StandardError.new
      allow(WhitehallImporter::Import).to receive(:call)
                                      .and_raise(error)

      expect($stdout).to receive(:puts).with("Import failed")
      expect($stdout).to receive(:puts).with("Error: #{error.inspect}")
      expect { Rake::Task["import:whitehall_document"].invoke("123") }
        .to raise_error(SystemExit)
    end
  end
end
