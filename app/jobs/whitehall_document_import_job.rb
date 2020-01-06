# frozen_string_literal: true

class WhitehallDocumentImportJob < ApplicationJob
  def perform(document_import)
    WhitehallImporter.import_and_sync(document_import)
    document_import.whitehall_migration&.check_migration_finished
  end
end
