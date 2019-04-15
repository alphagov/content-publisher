# frozen_string_literal: true

class FileAttachment < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true

  def readonly?
    !new_record?
  end
end
