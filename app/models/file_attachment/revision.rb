# frozen_string_literal: true

# A File Attachment revision represents an edit of a particular file attachment
#
# This is an immutable model
class FileAttachment::Revision < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true
  belongs_to :file_attachment, class_name: "FileAttachment"
  belongs_to :metadata_revision, class_name: "FileAttachment::MetadataRevision"
  belongs_to :blob_revision, class_name: "FileAttachment::BlobRevision", foreign_key: "file_revision_id"

  has_and_belongs_to_many :revisions,
                          class_name: "::Revision",
                          foreign_key: "file_attachment_revision_id",
                          join_table: "revisions_file_attachment_revisions"

  delegate :title, to: :metadata_revision
  delegate :filename,
           :asset,
           :assets,
           :ensure_assets,
           to: :blob_revision

  # TODO: Remove after breaking migration
  alias_attribute :blob_revision_id, :file_revision_id

  def readonly?
    !new_record?
  end
end
