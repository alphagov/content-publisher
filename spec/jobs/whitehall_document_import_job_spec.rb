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
    let(:error) { GdsApi::BaseError.new }
    before do
      allow(WhitehallImporter).to receive(:import_and_sync)
                              .and_raise(error)
    end

    it "retries the job" do
      WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)

      expect(WhitehallDocumentImportJob).to have_been_enqueued
    end

    it "logs the error when retries have been exhausted" do
      perform_enqueued_jobs do
        WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)
      end

      whitehall_migration_document_import.reload
      expect(whitehall_migration_document_import.error_log).to eq(error.inspect)
    end

    it "updates the document import state to 'import_failed' if the import failed" do
      perform_enqueued_jobs do
        WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)
      end

      whitehall_migration_document_import.reload
      expect(whitehall_migration_document_import).to be_import_failed
    end

    it "updates the document import state to 'sync_failed' if the sync failed" do
      whitehall_migration_document_import.update!(state: "imported")

      perform_enqueued_jobs do
        WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)
      end

      whitehall_migration_document_import.reload
      expect(whitehall_migration_document_import).to be_sync_failed
    end
  end
end
