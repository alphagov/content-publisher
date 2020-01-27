# frozen_string_literal: true

require "gds_api/whitehall_export"

module WhitehallImporter
  def self.create_migration(organisation_content_id, document_type)
    whitehall_migration = ActiveRecord::Base.transaction do
      record = WhitehallMigration.create!(organisation_content_id: organisation_content_id,
                                          document_type: document_type)

      whitehall_export = GdsApi.whitehall_export.document_list(organisation_content_id, document_type)

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
    raise "Cannot import with a state of #{whitehall_import.state}" unless whitehall_import.pending?

    whitehall_document = GdsApi.whitehall_export.document_export(whitehall_import.whitehall_document_id).to_h
    whitehall_import.update!(
      payload: whitehall_document,
      content_id: whitehall_document["content_id"],
      state: "importing",
    )

    import(whitehall_import)

    sync(whitehall_import) if whitehall_import.imported?

    whitehall_import
  end

  def self.import(whitehall_import)
    raise "Cannot import with a state of #{whitehall_import.state}" unless whitehall_import.importing?

    begin
      Import.call(whitehall_import)
    rescue IntegrityCheckError => e
      whitehall_import.update!(
        error_log: e.inspect,
        state: "import_aborted",
        integrity_check_problems: e.problems,
        integrity_check_proposed_payload: e.payload,
      )
    rescue AbortImportError => e
      whitehall_import.update!(error_log: e.inspect, state: "import_aborted")
    rescue StandardError => e
      whitehall_import.update!(error_log: e.inspect, state: "import_failed")
    end
  end

  def self.sync(whitehall_import)
    raise "Cannot sync with a state of #{whitehall_import.state}" unless whitehall_import.imported?

    begin
      whitehall_import.update!(state: "syncing")

      ResyncDocumentService.call(whitehall_import.document)
      ClearLinksetLinks.call(whitehall_import.document.content_id)
      MigrateAssets.call(whitehall_import)

      whitehall_import.update!(state: "completed")
    rescue StandardError => e
      whitehall_import.update!(error_log: e.inspect, state: "sync_failed")
    end
  end
end
