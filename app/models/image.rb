# frozen_string_literal: true

class Image < ApplicationRecord
  has_paper_trail

  WIDTH = 960
  HEIGHT = 640
  THUMBNAIL_WIDTH = 300
  THUMBNAIL_HEIGHT = 200

  PUBLICATION_STATES = %w[
    absent
    draft
    live
  ].freeze

  after_destroy { blob.delete }

  belongs_to :document
  belongs_to :blob, class_name: "ActiveStorage::Blob"

  validates_inclusion_of :publication_state, in: PUBLICATION_STATES

  def thumbnail
    crop_variant("#{THUMBNAIL_WIDTH}x#{THUMBNAIL_HEIGHT}")
  end

  def crop_variant(resize = "#{WIDTH}x#{HEIGHT}")
    crop = "#{crop_width}x#{crop_height}+#{crop_x}+#{crop_y}"
    blob.variant(
      crop: crop,
      resize: resize,
    )
  end

  def asset_manager_id
    url_array = asset_manager_file_url.to_s.split("/")
    # https://github.com/alphagov/asset-manager#create-an-asset
    url_array[url_array.length - 2]
  end

  def content_type
    blob.content_type
  end

  def cropped_bytes
    processed_image = thumbnail.processed
    processed_image.service.download(processed_image.key)
  end

  def at_exact_dimensions?
    width == WIDTH && height == HEIGHT
  end
end
