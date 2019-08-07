# frozen_string_literal: true

class ImageNormaliser::TempImage
  delegate :original_filename, to: :raw_file
  delegate :frames, to: :raw_image

  def initialize(raw_file)
    @raw_file = raw_file
    @raw_image = MiniMagick::Image.open(raw_file.path)
    @tempfile = Tempfile.new
  end

  def width
    dimensions[:width]
  end

  def height
    dimensions[:height]
  end

  def file
    @file ||= tempfile.tap do |tf|
      normalise_image
      raw_image.write(tf.path)
    end
  end

  def mime_type
    Marcel::MimeType.for(raw_file)
  end

private

  attr_reader :raw_file, :raw_image, :tempfile

  def normalise_image
    raw_image.combine_options do |options|
      options.auto_orient # apply any orientation specified as exif data
      options.strip # remove exif data as this may reveal more than publishers expect
    end
  end

  def dimensions
    if %w[RightTop LeftBottom].include?(raw_image["%[orientation]"])
      { width: raw_image.height, height: raw_image.width }
    else
      { width: raw_image.width, height: raw_image.height }
    end
  end
end
