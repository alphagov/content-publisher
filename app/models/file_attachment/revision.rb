# frozen_string_literal: true

# A File Attachment revision represents an edit of a particular file attachment
#
# This is an immutable model
class FileAttachment::Revision < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :file_attachment, class_name: "FileAttachment"
  belongs_to :metadata_revision, class_name: "FileAttachment::MetadataRevision"
  belongs_to :file_revision, class_name: "FileAttachment::FileRevision"

  # TODO this picks the wrong table (Image::Revision also broken)
  has_and_belongs_to_many :revisions

  delegate :title, to: :metadata_revision
  delegate :filename, to: :file_revision

  def readonly?
    !new_record?
  end
end
