RSpec.describe WhitehallDocumentImportJob do
  include ActiveJob::TestHelper

  let(:whitehall_migration) { create(:whitehall_migration) }
  let(:whitehall_host) { Plek.new.external_url_for("whitehall-admin") }

  let(:whitehall_migration_document_import) do
    create(:whitehall_migration_document_import,
           whitehall_migration_id: whitehall_migration["id"])
  end

  let(:imported_document_import) do
    create(:whitehall_migration_document_import, state: "imported")
  end

  before do
    allow(WhitehallImporter::Import).to receive(:call)
    allow(WhitehallImporter::Sync).to receive(:call)
    allow(whitehall_migration).to receive(:check_migration_finished)
    stub_whitehall_unlock_document(
      whitehall_migration_document_import.whitehall_document_id,
    )
  end

  it "calls WhitehallImporter::Import" do
    expect(WhitehallImporter::Import).to receive(:call)
                                     .with(whitehall_migration_document_import)
    WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)
  end

  it "calls WhitehallImporter::Sync" do
    expect(WhitehallImporter::Sync).to receive(:call)
                                   .with(whitehall_migration_document_import)
    WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)
  end

  it "calls on the mark migration completed method" do
    expect(whitehall_migration_document_import.whitehall_migration)
      .to receive(:check_migration_finished)
    WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)
  end

  context "when an error is raised" do
    let(:error_message) { "an error" }

    before do
      allow(WhitehallImporter::Import).to receive(:call).and_raise(error_message)
    end

    it "calls on the mark migration completed method" do
      expect(whitehall_migration_document_import.whitehall_migration)
        .to receive(:check_migration_finished)

      WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)
    end
  end

  context "when the import fails" do
    let(:error_message) { "import failed error" }

    before do
      allow(WhitehallImporter::Import).to receive(:call).and_raise(error_message)
    end

    it "unlocks the document in Whitehall" do
      request = stub_whitehall_unlock_document(
        whitehall_migration_document_import.whitehall_document_id,
      )

      WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)
      expect(request).to have_been_requested
    end

    it "updates the document import state to 'import_failed'" do
      WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)

      whitehall_migration_document_import.reload
      expect(whitehall_migration_document_import).to be_import_failed
    end
  end

  context "when the sync fails" do
    let(:error_message) { "sync failed error" }

    before do
      allow(WhitehallImporter::Sync).to receive(:call).and_raise(error_message)
    end

    it "does not unlock the document in Whitehall" do
      request = stub_whitehall_unlock_document(
        imported_document_import.whitehall_document_id,
      )

      WhitehallDocumentImportJob.perform_now(imported_document_import)
      expect(request).not_to have_been_requested
    end

    it "updates the document import state to 'sync_failed'" do
      WhitehallDocumentImportJob.perform_now(imported_document_import)

      imported_document_import.reload
      expect(imported_document_import).to be_sync_failed
    end
  end

  context "when a GdsApi::BaseError exception is raised" do
    let(:error) { GdsApi::BaseError.new }

    before do
      allow(WhitehallImporter::Import).to receive(:call).and_raise(error)
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
  end

  context "when a StandardError exception is raised" do
    let(:error) { StandardError.new }

    before do
      allow(WhitehallImporter::Import).to receive(:call).and_raise(error)
      stub_whitehall_unlock_document(
        whitehall_migration_document_import.whitehall_document_id,
      )
    end

    it "does not retry the job and logs the error" do
      WhitehallDocumentImportJob.perform_now(whitehall_migration_document_import)

      whitehall_migration_document_import.reload
      expect(WhitehallDocumentImportJob).not_to have_been_enqueued
      expect(whitehall_migration_document_import.error_log).to eq(error.inspect)
    end
  end

  context "when an AbortImportError exception is raised" do
    let(:error) { WhitehallImporter::AbortImportError.new("Aborted") }

    before do
      allow(WhitehallImporter::Import).to receive(:call).and_raise(error)
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
      allow(WhitehallImporter::Import).to receive(:call).and_raise(error)
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

  context "when the Whitehall unlock API call fails" do
    let(:error) { StandardError.new }

    before do
      allow(WhitehallImporter::Import).to receive(:call).and_raise("import error")
      stub_whitehall_unlock_document_error(
        whitehall_migration_document_import.whitehall_document_id, error
      )
    end

    it "updates the document import state to 'import_failed' and logs the error" do
      job = WhitehallDocumentImportJob
      log_message = "Failed to unlock Whitehall document: #{error.inspect}"
      expect(job.logger).to receive(:warn).with(log_message)

      job.perform_now(whitehall_migration_document_import)

      expect(whitehall_migration_document_import).to be_import_failed
    end
  end

  def stub_whitehall_unlock_document(document_id)
    stub_request(:post, "#{whitehall_host}/government/admin/export/document/#{document_id}/unlock")
  end

  def stub_whitehall_unlock_document_error(document_id, error)
    stub_request(:post, "#{whitehall_host}/government/admin/export/document/#{document_id}/unlock")
      .to_raise(error)
  end
end
