# frozen_string_literal: true

# Represents all versions of a particular image. Each change is represented
# as an ImageRevision.
#
# This model is immutable
class Image < ApplicationRecord
  WIDTH = 960
  HEIGHT = 640
  THUMBNAIL_WIDTH = 300
  THUMBNAIL_HEIGHT = 200

  belongs_to :created_by, class_name: "User", optional: true

  has_many :image_revisions, class_name: "Image::Revision"

  def readonly?
    !new_record?
  end
end
