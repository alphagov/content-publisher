require "gds_api/whitehall_export"

module WhitehallImporter
  class Sync
    attr_reader :whitehall_import

    def self.call(...)
      new(...).call
    end

    def initialize(whitehall_import)
      @whitehall_import = whitehall_import
    end

    def call
      unless whitehall_import.imported?
        raise "Cannot sync with a state of #{whitehall_import.state}"
      end

      ResyncDocumentService.call(whitehall_import.document)
      ClearLinksetLinks.call(whitehall_import.document.content_id)
      GdsApi.whitehall_export.document_migrated(
        whitehall_import.whitehall_document_id,
      )

      whitehall_import.update!(state: "completed")
    end
  end
end
