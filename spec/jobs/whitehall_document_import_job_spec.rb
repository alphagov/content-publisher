RSpec.describe WhitehallDocumentImportJob do
  include ActiveJob::TestHelper

  let(:whitehall_migration_document_import) {
    build(:whitehall_migration_document_import)
  }

  it "calls on the import and sync method" do
    expect(WhitehallImporter).to receive(:import_and_sync).with(whitehall_migration_document_import)
    WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)
  end
end
