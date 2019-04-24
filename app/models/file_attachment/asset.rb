# frozen_string_literal: true

# A FileAttachment::Asset is used to interface with Asset Manager to represent a
# file uploaded as part of a FileAttachment::Revision. It is used to track the
# state of the media on Asset Manager and its URL.
#
# This is a mutable model that is mutated when state changes on Asset Manager
class FileAttachment::Asset < ApplicationRecord
  belongs_to :blob_revision,
             class_name: "FileAttachment::BlobRevision",
             foreign_key: "file_revision_id"

  enum state: { absent: "absent",
                draft: "draft",
                live: "live" }

  enum variant: { file: "file", thumbnail: "thumbnail" }

  delegate :filename, :content_type, to: :blob_revision

  # TODO: Remove after breaking migration
  alias_attribute :blob_revision_id, :file_revision_id

  def bytes
    blob_revision.bytes_for_asset(variant)
  end
end
