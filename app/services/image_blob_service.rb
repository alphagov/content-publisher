# frozen_string_literal: true

require "mini_magick"

class ImageBlobService
  def initialize(revision, user)
    @revision = revision
    @user = user
  end

  def create_blob_revision(file)
    mime_type = Marcel::MimeType.for(file)
    filename = unique_filename(file)
    image_normaliser = ImageNormaliser.new(file.path)

    blob = ActiveStorage::Blob.create_after_upload!(
      io: image_normaliser.normalised_file,
      filename: filename,
      content_type: mime_type,
    )

    blob_revision(blob, filename, image_normaliser)
  end

private

  attr_reader :revision, :user

  def unique_filename(file)
    filenames = revision.image_revisions.map(&:filename)
    UniqueFilenameService.new(filenames).call(file.original_filename)
  end

  def blob_revision(blob, filename, image_normaliser)
    dimensions = image_normaliser.dimensions

    centre_crop = CentreCrop.new(dimensions[:width],
                                 dimensions[:height]).dimensions

    Image::BlobRevision.create!(
      blob: blob,
      width: dimensions[:width],
      height: dimensions[:height],
      crop_x: centre_crop[:x],
      crop_y: centre_crop[:y],
      crop_width: centre_crop[:width],
      crop_height: centre_crop[:height],
      filename: filename,
      created_by: user,
    )
  end
end
