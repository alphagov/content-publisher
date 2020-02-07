# frozen_string_literal: true

module WhitehallImporter
  class Sync
    attr_reader :whitehall_import

    def self.call(*args)
      new(*args).call
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
      MigrateAssets.call(whitehall_import)

      whitehall_import.update!(state: "completed")
    end
  end
end
