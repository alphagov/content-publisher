# frozen_string_literal: true

class Image < ApplicationRecord
  WIDTH = 960
  HEIGHT = 640

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

  def crop_variant
    crop = "#{crop_width}x#{crop_height}+#{crop_x}+#{crop_y}"
    blob.variant(
      crop: crop,
      resize: "#{WIDTH}x#{HEIGHT}",
    )
  end
end
