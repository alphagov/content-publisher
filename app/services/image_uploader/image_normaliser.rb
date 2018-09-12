# frozen_string_literal: true

require "mini_magick"

class ImageUploader::ImageNormaliser
  attr_reader :image

  def initialize(image_path)
    @image = MiniMagick::Image.new(image_path)
  end

  def dimensions
    if %w[RightTop LeftBottom].include?(image["%[orientation]"])
      { width: image.height, height: image.width }
    else
      { width: image.width, height: image.height }
    end
  end

  def normalise
    image.combine_options do |file|
      # apply any orientation specified as exif data
      file.auto_orient

      # remove exif data as this may reveal more than publishers expect
      file.strip
    end
  end
end
