# frozen_string_literal: true

require "mini_magick"

class ImageUploader
  include ActionView::Helpers::NumberHelper

  MAX_FILE_SIZE = 20.megabytes

  def initialize(file)
    @file = file
  end

  def valid?
    errors.empty?
  end

  def errors
    @errors ||= validate
  end

  def upload(document)
    blob = ActiveStorage::Blob.create_after_upload!(
      io: image_normaliser.normalised_file,
      filename: filename,
      content_type: mime_type,
    )

    image_attributes = { document: document,
                         blob: blob,
                         filename: filename }.merge(dimension_attributes)
    Image.new(image_attributes)
  end

private

  attr_reader :file

  def filename
    file.respond_to?(:original_filename) ? file.original_filename : File.basename(file)
  end

  def mime_type
    @mime_type ||= Marcel::MimeType.for(file)
  end

  def image_normaliser
    @image_normaliser ||= ImageNormaliser.new(file.path)
  end

  def dimension_attributes
    dimensions = image_normaliser.dimensions
    cropper = CentreCropper.new(dimensions[:width],
                                dimensions[:height],
                                Image::WIDTH.to_f / Image::HEIGHT)
    {
      width: dimensions[:width],
      height: dimensions[:height],
      crop_x: cropper.dimensions[:x],
      crop_y: cropper.dimensions[:y],
      crop_width: cropper.dimensions[:width],
      crop_height: cropper.dimensions[:height],
    }
  end

  def validate
    if %w(image/jpeg image/png image/gif).exclude?(mime_type)
      return [I18n.t("validations.images.invalid_format")]
    end

    errors = []

    if file.size >= MAX_FILE_SIZE
      errors << I18n.t("validations.images.max_size",
                       max_size: number_to_human_size(MAX_FILE_SIZE))
    end

    dimensions = image_normaliser.dimensions

    if dimensions[:width] < Image::WIDTH || dimensions[:height] < Image::HEIGHT
      errors << I18n.t("validations.images.min_dimensions",
                       width: Image::WIDTH,
                       height: Image::HEIGHT)
    end

    errors
  end
end
