# frozen_string_literal: true

module WhitehallImporter
  def self.import_and_sync(whitehall_document)
    whitehall_import = WhitehallImport.create!(
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
    document = Import.call(whitehall_import.payload)
    whitehall_import.update!(document: document, state: "imported")
  rescue AbortImportError => e
    whitehall_import.update!(error_log: e.inspect, state: "import_aborted")
  rescue StandardError => e
    whitehall_import.update!(error_log: e.inspect, state: "import_failed")
  end

  def self.sync(whitehall_import)
    whitehall_import.update!(state: "syncing")

    ResyncService.call(whitehall_import.document)
    ClearLinksetLinks.call(whitehall_import.document.content_id)

    whitehall_import.update!(state: "completed")
  rescue StandardError => e
    whitehall_import.update!(error_log: e.inspect, state: "sync_failed")
  end
end
