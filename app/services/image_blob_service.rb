# frozen_string_literal: true

require "mini_magick"

class ImageBlobService
  def initialize(revision, user, temp_image)
    @revision = revision
    @user = user
    @temp_image = temp_image
  end

  def call
    blob = ActiveStorage::Blob.create_after_upload!(
      io: temp_image.file,
      filename: unique_filename,
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
      filename: unique_filename,
      created_by: user,
    )
  end

private

  attr_reader :revision, :user, :temp_image

  def unique_filename
    filenames = revision.image_revisions.map(&:filename)

    @unique_filename ||= UniqueFilenameService.new(filenames)
      .call(temp_image.original_filename)
  end

  def centre_crop
    @centre_crop ||= CentreCrop.new(temp_image.width,
                                    temp_image.height).dimensions
  end
end
