# frozen_string_literal: true

class WhitehallDocumentImportJob < ApplicationJob
  def perform(whitehall_migration_document_import)
    WhitehallImporter.import_and_sync(whitehall_migration_document_import)
  end
end
