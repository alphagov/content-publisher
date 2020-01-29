# frozen_string_literal: true

class WhitehallDocumentImportJob < ApplicationJob
  # retry at 3s, 18s, 83s, 258s, 627s
  retry_on(GdsApi::BaseError, attempts: 5, wait: :exponentially_longer) do |job, error|
    document_import = job.arguments.first
    state = document_import.imported? ? "sync_failed" : "import_failed"
    document_import.update!(state: state, error_log: error.inspect)
  end

  def perform(document_import)
    WhitehallImporter.import_and_sync(document_import)
    document_import.whitehall_migration&.check_migration_finished
  end
end
