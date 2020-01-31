# frozen_string_literal: true

require "gds_api/whitehall_export"

module WhitehallImporter
  def self.create_migration(organisation_content_id, document_type, document_subtypes = [])
    whitehall_migration = ActiveRecord::Base.transaction do
      record = WhitehallMigration.create!(organisation_content_id: organisation_content_id,
                                          document_type: document_type,
                                          document_subtypes: document_subtypes)

      whitehall_export = GdsApi.whitehall_export.document_list(organisation_content_id, document_type, document_subtypes)

      whitehall_export.each do |page|
        page["documents"].each do |document|
          WhitehallMigration::DocumentImport.create!(
            whitehall_document_id: document["document_id"],
            whitehall_migration_id: record.id,
            state: "pending",
          )
        end
      end
      record
    end
    whitehall_migration.document_imports.find_each do |document_import|
      WhitehallDocumentImportJob.perform_later(document_import)
    end
    whitehall_migration
  end

  def self.import_and_sync(whitehall_import)
    whitehall_import = Import.call(whitehall_import)

    Sync.call(whitehall_import) if whitehall_import.imported?
  end
end
