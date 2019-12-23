# frozen_string_literal: true

# Represents the raw import of an asset from Whitehall Publisher and
# the import status of the asset into Content Publisher
class WhitehallMigration::AssetImport < ApplicationRecord
  belongs_to :document_import
  belongs_to :image_revision, class_name: "Image::Revision", optional: true
  belongs_to :file_attachment_revision, class_name: "FileAttachment::Revision", optional: true

  enum state: { redirected: "redirected",
                removed: "removed",
                migration_failed: "migration_failed",
                pending: "pending" }
end
