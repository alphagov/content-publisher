# frozen_string_literal: true

require "mini_magick"

class UploadedImageService
  WIDTH = 960
  HEIGHT = 640
  MAX_FILE_SIZE = 20.megabytes

  def initialize(upload)
    @upload = upload
  end

  def process
    errors = validate

    return InvalidImage.new(errors: errors) if errors.any?

    image_normaliser.normalise
    dimensions = image_normaliser.dimensions
    cropper = CentreCropper.new(dimensions[:width], dimensions[:height], WIDTH.to_f / HEIGHT)

    ValidImage.new(
      file: upload,
      mime_type: mime_type,
      filename: upload.original_filename,
      dimensions: dimensions,
      crop_dimensions: cropper.dimensions,
    )
  end

private

  attr_reader :upload

  def mime_type
    @mime_type ||= Marcel::MimeType.for(upload)
  end

  def image_normaliser
    @image_normaliser ||= ImageNormaliser.new(upload.path)
  end

  def validate
    if %w(image/jpeg image/png image/gif).exclude?(mime_type)
      return ["Expected a jpg, png or gif image"]
    end

    errors = []

    if upload.size >= MAX_FILE_SIZE
      errors << "Image uploads must be less than 20MB in filesize"
    end

    dimensions = image_normaliser.dimensions

    if dimensions[:width] < WIDTH || dimensions[:height] < HEIGHT
      errors << "Images must have dimensions of at least #{WIDTH} x #{HEIGHT} pixels"
    end

    errors
  end

  class InvalidImage
    include ActiveModel::Model
    attr_accessor :errors

    def valid?
      false
    end
  end

  class ValidImage
    include ActiveModel::Model
    attr_accessor :file, :mime_type, :filename, :dimensions, :crop_dimensions

    def valid?
      true
    end
  end
end
