# frozen_string_literal: true

module WhitehallImporter
  def self.import(whitehall_document)
    record = WhitehallImport.create!(
      whitehall_document_id: whitehall_document["id"],
      payload: whitehall_document,
      content_id: whitehall_document["content_id"],
      state: "importing",
    )

    begin
      Import.call(record)
      record.update!(state: "completed")
    rescue StandardError => e
      record.update!(error_log: e.message,
                     state: "failed")
    end

    record
  end

  def self.migrate_whitehall_content(document)
    record_of_import = WhitehallImport.find_by(document: document)

    raise AbortMigrateUpstreamError unless record_of_import

    WhitehallImportedAsset.find_by(
      whitehall_import: record_of_import,
      state: "not_processed",
    ).each(&:call)
  end
end
