RSpec.describe "Import tasks" do
  include ActiveJob::TestHelper

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
    before do
      allow($stdout).to receive(:puts)
      Rake::Task["import:whitehall_document"].reenable
    end

    it "creates a pending whitehall migration document import" do
      allow(WhitehallDocumentImportJob).to receive(:perform_later)

      expect { Rake::Task["import:whitehall_document"].invoke("123") }
        .to change { WhitehallMigration::DocumentImport.pending.exists?(whitehall_document_id: 123) }
        .to(true)
    end

    it "queues a job for the document to be imported" do
      Rake::Task["import:whitehall_document"].invoke("123")
      expect(WhitehallDocumentImportJob).to have_been_enqueued.with(
        an_instance_of(WhitehallMigration::DocumentImport),
      )
    end
  end
end
