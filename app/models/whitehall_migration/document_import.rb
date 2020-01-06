# frozen_string_literal: true

# Represents the raw import of a document from Whitehall Publisher and
# the import status of the document into Content Publisher
class WhitehallMigration::DocumentImport < ApplicationRecord
  belongs_to :document, optional: true

  belongs_to :whitehall_migration, optional: true

  has_many :assets, class_name: "WhitehallMigration::AssetImport"

  enum state: { pending: "pending",
                importing: "importing",
                imported: "imported",
                import_aborted: "import_aborted",
                import_failed: "import_failed",
                syncing: "syncing",
                sync_failed: "sync failed",
                completed: "completed" }

  scope :in_progress, -> { pending.or(importing).or(imported).or(syncing) }

  def migratable_assets
    assets.select { |a| a.pending? || a.migration_failed? }
  end
end
