# frozen_string_literal: true

RSpec.describe WhitehallDocumentImportJob do
  include ActiveJob::TestHelper

  let(:whitehall_migration) { create(:whitehall_migration) }

  let(:whitehall_migration_document_import) do
    create(:whitehall_migration_document_import, whitehall_migration_id: whitehall_migration["id"], state: "pending")
  end

  before do
    allow(WhitehallImporter).to receive(:import_and_sync)
    allow(whitehall_migration).to receive(:check_migration_finished)
  end

  it "calls on the import and sync method" do
    expect(WhitehallImporter).to receive(:import_and_sync).with(whitehall_migration_document_import)
    WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)
  end

  it "calls on the mark migration completed method" do
    expect(whitehall_migration_document_import.whitehall_migration).to receive(:check_migration_finished)
    WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)
  end

  context "when a GdsApi::BaseError exception is raised" do
    it "retries the job" do
      allow(WhitehallImporter).to receive(:import_and_sync)
                              .and_raise(GdsApi::BaseError)
      WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)

      expect(WhitehallDocumentImportJob).to have_been_enqueued
    end
  end
end
