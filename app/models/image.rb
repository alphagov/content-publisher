# frozen_string_literal: true

class Image < ApplicationRecord
  belongs_to :document
  belongs_to :blob, class_name: "ActiveStorage::Blob" # rubocop:disable Rails/InverseOf

  WIDTH = 960
  HEIGHT = 640

  def crop_variant
    crop = "#{crop_width}x#{crop_height}+#{crop_x}+#{crop_y}"
    blob.variant(
      crop: crop,
      resize: "#{WIDTH}x#{HEIGHT}",
    )
  end
end
