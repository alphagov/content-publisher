# frozen_string_literal: true

# Represents the raw import of an asset from Whitehall Publisher and
# the import status of the asset into Content Publisher
class WhitehallImportedAsset < ApplicationRecord
  belongs_to :whitehall_import

  belongs_to :image_revision, class_name: "Image::Revision", optional: true
  belongs_to :file_attachment_revision, class_name: "FileAttachment::Revision", optional: true

  validate :associated_with_only_image_or_file_attachment

  def revision
    if image_revision.present?
      image_revision
    elsif file_attachment_revision.present?
      file_attachment_revision
    end
  end

  def asset_manager_id
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
