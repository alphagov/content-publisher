# frozen_string_literal: true

module WhitehallImporter
  def self.create_migration(organisation_content_id, document_type)
    ActiveRecord::Base.transaction do
      whitehall_migration = WhitehallMigration.create!(organisation_content_id: organisation_content_id,
                                 document_type: document_type,
                                 start_time: Time.current)

      whitehall_export = GdsApi.whitehall_export.document_list(organisation_content_id, document_type)

      whitehall_export.each do |page|
        page["documents"].each do |document|
          WhitehallMigration::DocumentImport.create!(
            whitehall_document_id: document["document_id"],
            whitehall_migration_id: whitehall_migration.id,
            state: "pending",
          )
        end
      end

      whitehall_migration
    end
  end

  def self.import_and_sync(whitehall_document)
    whitehall_import = WhitehallMigration::DocumentImport.create!(
      whitehall_document_id: whitehall_document["id"],
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
      document = Import.call(whitehall_import)
      whitehall_import.update!(document: document, state: "imported")
      create_timeline_entry(document.current_edition)
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

      ResyncService.call(whitehall_import.document)
      ClearLinksetLinks.call(whitehall_import.document.content_id)

      whitehall_import.update!(state: "completed")
    rescue StandardError => e
      whitehall_import.update!(error_log: e.inspect, state: "sync_failed")
    end
  end

  def self.create_timeline_entry(edition)
    TimelineEntry.create_for_revision(
      entry_type: :imported_from_whitehall,
      revision: edition.revision,
      edition: edition,
    )
  end

  private_class_method :create_timeline_entry
end
