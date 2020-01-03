# frozen_string_literal: true

class WhitehallDocumentImportJob < ApplicationJob
  def perform(document_import)
    WhitehallImporter.import_and_sync(document_import)
  end
end
