# frozen_string_literal: true

require "mini_magick"

class ImageBlobService < ApplicationService
  def initialize(temp_image:, filename:, user: nil)
    @temp_image = temp_image
    @filename = filename
    @user = user
  end

  def call
    blob = ActiveStorage::Blob.create_after_upload!(
      io: temp_image.file,
      filename: filename,
      content_type: temp_image.mime_type,
    )

    Image::BlobRevision.create!(
      blob: blob,
      width: temp_image.width,
      height: temp_image.height,
      crop_x: centre_crop[:x],
      crop_y: centre_crop[:y],
      crop_width: centre_crop[:width],
      crop_height: centre_crop[:height],
      filename: filename,
      created_by: user,
    )
  end

private

  attr_reader :temp_image, :filename, :user

  def centre_crop
    @centre_crop ||= CentreCrop.new(temp_image.width,
                                    temp_image.height).dimensions
  end
end
