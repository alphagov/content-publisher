# frozen_string_literal: true

# This is an immutable model
class FileAttachment::FileRevision < ApplicationRecord
  belongs_to :blob, class_name: "ActiveStorage::Blob"

  belongs_to :created_by, class_name: "User", optional: true

  has_many :assets, class_name: "FileAttachment::Asset"

  delegate :content_type, to: :blob

  def readonly?
    !new_record?
  end
end
