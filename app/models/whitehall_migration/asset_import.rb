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

  validate :associated_with_only_image_or_file_attachment

  def whitehall_asset_id
    url_array = original_asset_url.to_s.split("/")
    # https://github.com/alphagov/asset-manager#create-an-asset
    url_array[url_array.length - 2]
  end

private

  def associated_with_only_image_or_file_attachment
    if image_revision.present? && file_attachment_revision.present?
      errors.add(:base, "Cannot be associated with both image revision AND file attachment revision")
    end
  end
end
