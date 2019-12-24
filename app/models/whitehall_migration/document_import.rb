# frozen_string_literal: true

# Represents the raw import of a document from Whitehall Publisher and
# the import status of the document into Content Publisher
class WhitehallMigration::DocumentImport < ApplicationRecord
  belongs_to :document, optional: true

  enum state: { pending: "pending",
                importing: "importing",
                imported: "imported",
                import_aborted: "import_aborted",
                import_failed: "import_failed",
                syncing: "syncing",
                sync_failed: "sync failed",
                completed: "completed" }
end
