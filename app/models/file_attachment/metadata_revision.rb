# frozen_string_literal: true

# This is an immutable model
class FileAttachment::MetadataRevision < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true

  def readonly?
    !new_record?
  end
end
