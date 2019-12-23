# frozen_string_literal: true

# Represents the raw import of an asset from Whitehall Publisher and
# the import status of the asset into Content Publisher
class WhitehallMigration::AssetImport < ApplicationRecord
  enum state: { redirected: "redirected",
                removed: "removed",
                migration_failed: "migration_failed",
                pending: "pending" }
end
