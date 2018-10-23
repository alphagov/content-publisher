# frozen_string_literal: true

require "mini_magick"

class ImageUploader
  def initialize(file)
    @file = file
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
end
