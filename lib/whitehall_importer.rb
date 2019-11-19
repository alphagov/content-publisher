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
      Import.call(whitehall_document)
      record.update!(state: "completed")
    rescue StandardError => e
      record.update!(error_log: e.message,
                     state: "failed")
    end

    record
  end
end
