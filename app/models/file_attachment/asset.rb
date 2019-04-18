# frozen_string_literal: true

# A FileAttachment::Asset is used to interface with Asset Manager to represent a
# file uploaded as part of a FileAttachment::Revision. It is used to track the
# state of the media on Asset Manager and its URL.
#
# This is a mutable model that is mutated when state changes on Asset Manager
class FileAttachment::Asset < ApplicationRecord
  belongs_to :file_revision,
             class_name: "FileAttachment::FileRevision"

  enum state: { absent: "absent",
                draft: "draft",
                live: "live" }

  enum variant: { file: "file", thumbnail: "thumbnail" }

  delegate :filename, :content_type, to: :file_revision

  def bytes
    raise "Cannot determine bytes for #{variant}" unless file?

    file_revision.bytes_for_file
  end
end
