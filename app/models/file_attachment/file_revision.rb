# frozen_string_literal: true

# This is an immutable model
class FileAttachment::FileRevision < ApplicationRecord
  belongs_to :blob, class_name: "ActiveStorage::Blob"

  belongs_to :created_by, class_name: "User", optional: true

  # There is an expectation there will also be a thumbnail asset
  has_one :file_asset,
          -> { where(variant: :file) },
          class_name: "FileAttachment::Asset",
          inverse_of: :file_revision

  delegate :content_type, to: :blob

  def readonly?
    !new_record?
  end

  def ensure_assets
    unless file_asset
      self.file_asset = FileAttachment::Asset.new(file_revision: self, variant: :file)
    end
  end
end
