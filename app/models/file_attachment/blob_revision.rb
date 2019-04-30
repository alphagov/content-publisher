# frozen_string_literal: true

# This is an immutable model
class FileAttachment::BlobRevision < ApplicationRecord
  belongs_to :blob, class_name: "ActiveStorage::Blob"

  belongs_to :created_by, class_name: "User", optional: true

  has_many :assets, class_name: "FileAttachment::Asset"

  delegate :content_type, :byte_size, to: :blob

  def readonly?
    !new_record?
  end

  def asset(variant)
    assets.find { |v| v.variant == variant }
  end

  def bytes_for_asset(variant)
    if variant == "file"
      blob.download
    else
      raise RuntimeError, "Unsupported blob revision variant #{variant}"
    end
  end

  def ensure_assets
    unless asset("file")
      assets << FileAttachment::Asset.new(blob_revision: self, variant: "file")
    end
  end
end
