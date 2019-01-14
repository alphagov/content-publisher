# frozen_string_literal: true

# A basic model that is used to join together a collection of image revisions
# with the item they represent. Thus two image_revisions that link to the
# same Image are considered two revision of that image.
class Image < ApplicationRecord
  self.table_name = "versioned_images"

  WIDTH = 960
  HEIGHT = 640
  THUMBNAIL_WIDTH = 300
  THUMBNAIL_HEIGHT = 200

  belongs_to :created_by, class_name: "User", optional: true

  has_many :image_revisions,
           class_name: "Image::Revision",
           inverse_of: :image,
           dependent: :restrict_with_exception

  def readonly?
    !new_record?
  end
end
