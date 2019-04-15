# frozen_string_literal: true

class FileAttachment < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true
  has_many :file_attachment_revisions, class_name: "FileAttachment::Revision"

  def readonly?
    !new_record?
  end
end
