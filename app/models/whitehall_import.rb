# frozen_string_literal: true

# Represents the raw import of a document from Whitehall Publisher and
# the import status of the document into Content Publisher
class WhitehallImport < ApplicationRecord
  belongs_to :document, optional: true
  has_many :whitehall_imported_assets
  alias_attribute :assets, :whitehall_imported_assets

  enum state: { importing: "importing",
                imported: "imported",
                import_aborted: "import_aborted",
                import_failed: "import_failed",
                syncing: "syncing",
                sync_failed: "sync failed",
                completed: "completed" }
end
