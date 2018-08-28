# frozen_string_literal: true

require "mini_magick"

class UploadedImageService
  MAX_FILE_SIZE = 20.megabytes

  def initialize(upload)
    @upload = upload
  end

  def process
    errors = validate

    return InvalidImage.new(errors: errors) if errors.any?

    image_normaliser.normalise
    dimensions = image_normaliser.dimensions
    cropper = CentreCropper.new(dimensions[:width],
                                dimensions[:height],
                                output_width.to_f / output_height)

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

  def output_width
    Image::WIDTH
  end

  def output_height
    Image::HEIGHT
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

    if dimensions[:width] < output_width || dimensions[:height] < output_height
      errors << "Images must have dimensions of at least #{output_width} x #{output_height} pixels"
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
