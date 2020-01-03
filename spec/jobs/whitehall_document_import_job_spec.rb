# frozen_string_literal: true

RSpec.describe WhitehallDocumentImportJob do
  include ActiveJob::TestHelper

  let(:whitehall_migration) { create(:whitehall_migration) }

  let(:whitehall_migration_document_import) do
    create(:whitehall_migration_document_import, whitehall_migration_id: whitehall_migration["id"], state: "pending")
  end

  before do
    allow(WhitehallImporter).to receive(:import_and_sync)
  end

  it "calls on the import and sync method" do
    expect(WhitehallImporter).to receive(:import_and_sync).with(whitehall_migration_document_import)
    WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)
  end
end
