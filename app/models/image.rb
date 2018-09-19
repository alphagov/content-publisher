# frozen_string_literal: true

class Image < ApplicationRecord
  WIDTH = 960
  HEIGHT = 640
  THUMBNAIL_WIDTH = 300
  THUMBNAIL_HEIGHT = 200

  after_destroy { blob.delete }

  belongs_to :document
  belongs_to :blob, class_name: "ActiveStorage::Blob"

  validates :width,
            numericality: { only_integer: true, greater_than_or_equal_to: WIDTH }
  validates :height,
            numericality: { only_integer: true, greater_than_or_equal_to: HEIGHT }
  validates :crop_x,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :crop_y,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :crop_width,
            numericality: { only_integer: true, greater_than_or_equal_to: WIDTH }
  validates :crop_height,
            numericality: { only_integer: true, greater_than_or_equal_to: HEIGHT }

  validates_with ImageAspectRatioValidator

  def thumbnail
    crop_variant("#{THUMBNAIL_WIDTH}x#{THUMBNAIL_HEIGHT}")
  end

  def crop_variant(resize = "#{WIDTH}x#{HEIGHT}")
    crop = "#{crop_width}x#{crop_height}+#{crop_x}+#{crop_y}"
    blob.variant(
      crop: crop,
      resize: resize,
    )
  end

  def asset_manager_id
    url_array = asset_manager_file_url.split("/")
    # https://github.com/alphagov/asset-manager#create-an-asset
    url_array[url_array.length - 2]
  end

  def cropped_bytes
    processed_image = thumbnail.processed
    processed_image.service.download(processed_image.key)
  end
end
