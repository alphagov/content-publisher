# frozen_string_literal: true

# This stores the metadata component of a revision, by metadata we mean
# supporting data that explains the revision which is represented by
# update_type and change_note fields.
#
# This model is immutable.
class MetadataRevision < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true

  enum update_type: { major: "major", minor: "minor" }

  def readonly?
    !new_record?
  end

  def document_type
    DocumentType.find(document_type_id)
  end
end
