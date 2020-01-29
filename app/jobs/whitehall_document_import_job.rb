# frozen_string_literal: true

class WhitehallDocumentImportJob < ApplicationJob
  discard_on(StandardError) do |job, error|
    document_import = job.arguments.first
    handle_error(document_import, error)
  end

  # retry at 3s, 18s, 83s, 258s, 627s
  retry_on(GdsApi::BaseError, attempts: 5, wait: :exponentially_longer) do |job, error|
    document_import = job.arguments.first
    handle_error(document_import, error)
  end

  def perform(document_import)
    WhitehallImporter.import_and_sync(document_import)
    document_import.whitehall_migration&.check_migration_finished
  end

  def self.handle_error(document_import, error)
    case error
    when WhitehallImporter::AbortImportError
      document_import.update!(state: "import_aborted", error_log: error.inspect)
    else
      state = document_import.imported? ? "sync_failed" : "import_failed"
      document_import.update!(state: state, error_log: error.inspect)
    end
  end
end
