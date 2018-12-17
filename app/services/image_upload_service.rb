# frozen_string_literal: true

require "mini_magick"

class ImageUploadService
  def initialize(document, file)
    @document = document
    @file = file
  end

  def call
    blob = ActiveStorage::Blob.create_after_upload!(
      io: normaliser.normalised_file,
      filename: filename,
      content_type: mime_type,
    )

    image = Image.new(image_attributes)
    image.document = document
    image.blob = blob
    image.asset_manager_file_url = upload_to_asset_manager(image)
    image.publication_state = "draft"
    image.save!
    image
  end

private

  attr_reader :document, :file

  def upload_to_asset_manager(image)
    AssetManagerService.new.upload_bytes(image, image.cropped_bytes)
  end

  def filename
    name = file.original_filename
    @filename ||= ImageFilenameService.new(document).call(name, mime_type)
  end

  def mime_type
    @mime_type ||= Marcel::MimeType.for(file)
  end

  def normaliser
    @normaliser ||= ImageNormaliser.new(file.path)
  end

  def dimensions
    @dimensions ||= normaliser.dimensions
  end

  def image_attributes
    cropper = ImageCentreCropper.new(dimensions[:width],
                                     dimensions[:height],
                                     Image::WIDTH.to_f / Image::HEIGHT)

    {
      width: dimensions[:width],
      height: dimensions[:height],
      crop_x: cropper.dimensions[:x],
      crop_y: cropper.dimensions[:y],
      crop_width: cropper.dimensions[:width],
      crop_height: cropper.dimensions[:height],
      filename: filename,
    }
  end
end
