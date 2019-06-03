# frozen_string_literal: true

# This is an immutable model
class FileAttachment::BlobRevision < ApplicationRecord
  belongs_to :blob, class_name: "ActiveStorage::Blob"

  belongs_to :created_by, class_name: "User", optional: true

  has_one :asset,
          class_name: "FileAttachment::Asset",
          inverse_of: :blob_revision,
          required: true

  delegate :content_type, :byte_size, to: :blob

  def readonly?
    !new_record?
  end

  def asset_url
    asset.file_url
  end

  def bytes_for_asset
    blob.download
  end
end
