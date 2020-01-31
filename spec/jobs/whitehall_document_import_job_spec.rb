# frozen_string_literal: true

RSpec.describe WhitehallDocumentImportJob do
  include ActiveJob::TestHelper

  let(:whitehall_migration) { create(:whitehall_migration) }

  let(:whitehall_migration_document_import) do
    create(:whitehall_migration_document_import, whitehall_migration_id: whitehall_migration["id"], state: "pending")
  end
  let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }

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

  context "when a StandardError exception is raised" do
    let(:error) { StandardError.new }
    before do
      allow(WhitehallImporter).to receive(:import_and_sync)
                              .and_raise(error)
    end

    it "does not retry the job, logs the error and updates the document import state" do
      WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)

      whitehall_migration_document_import.reload
      expect(WhitehallDocumentImportJob).not_to have_been_enqueued
      expect(whitehall_migration_document_import.error_log).to eq(error.inspect)
      expect(whitehall_migration_document_import).to be_import_failed
    end
  end

  context "when an AbortImportError exception is raised" do
    let(:error) { WhitehallImporter::AbortImportError.new("Aborted") }
    before do
      allow(WhitehallImporter).to receive(:import_and_sync)
                              .and_raise(error)
    end

    it "updates the document import state to 'import_aborted' and saves the error" do
      WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)
      whitehall_migration_document_import.reload

      expect(whitehall_migration_document_import).to be_import_aborted
      expect(whitehall_migration_document_import.error_log).to eq(error.inspect)
    end
  end

  context "when an IntegrityCheckError exception is raised" do
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
    let(:error) { WhitehallImporter::IntegrityCheckError.new(integrity_check) }

    before do
      allow(WhitehallImporter).to receive(:import_and_sync)
                              .and_raise(error)
    end

    it "updates the document import state to 'import_aborted'" do
      WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)
      whitehall_migration_document_import.reload

      expect(whitehall_migration_document_import).to be_import_aborted
      expect(whitehall_migration_document_import.error_log).to eq(error.inspect)
      expect(whitehall_migration_document_import.integrity_check_problems)
        .to eq(problems)
      expect(whitehall_migration_document_import.integrity_check_proposed_payload)
        .to eq(payload)
    end
  end
end
