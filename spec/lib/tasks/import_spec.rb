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
    before do
      Rake::Task["import:whitehall_document"].reenable
    end

    it "imports the export and syncs with publishing-api" do
      import = build(:whitehall_migration_document_import, state: "completed")

      allow(WhitehallMigration::DocumentImport).to receive(:create!).and_return(import)
      expect(WhitehallImporter).to receive(:import_and_sync).with(import)

      Rake::Task["import:whitehall_document"].invoke("123")
    end

    it "creates a pending whitehall migration document import" do
      allow(WhitehallImporter).to receive(:import_and_sync)
      allow_any_instance_of(WhitehallMigration::DocumentImport).to receive(:completed?).and_return(true)

      expect { Rake::Task["import:whitehall_document"].invoke("123") }
        .to change { WhitehallMigration::DocumentImport.pending.exists?(whitehall_document_id: 123) }
        .to(true)
    end

    it "aborts if the import fails" do
      allow($stdout).to receive(:puts)

      import = build(:whitehall_migration_document_import,
                     state: :import_failed,
                     error_log: "Error importing")
      allow(WhitehallMigration::DocumentImport).to receive(:create!).and_return(import)
      expect(WhitehallImporter).to receive(:import_and_sync).and_return(import)

      expect($stdout).to receive(:puts).with("Import failed")
      expect($stdout).to receive(:puts).with("Error: Error importing")
      expect { Rake::Task["import:whitehall_document"].invoke("123") }
        .to raise_error(SystemExit)
    end
  end
end
