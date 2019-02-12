# frozen_string_literal: true

# This model stores data of Image::Revision which affects the resultant files
# that are sent to Asset Manager. Any change to data in here will mean new
# files need to be sent. It has a one to many association with
# Image::Asset each of which represent an Asset that should be on Asset
# Manager when this image is viewable.
# This also stores the association to the ActiveStorage::Blob that is
# behind an Image and is responsible for being able to do transformations on
# the underlying blob.
#
# This is an immutable model.
class Image::FileRevision < ApplicationRecord
  # FIXME: we should see if these can be retina variants
  ASSET_VARIANTS = %w[300 960 high_resolution].freeze

  belongs_to :blob, class_name: "ActiveStorage::Blob"

  belongs_to :created_by, class_name: "User", optional: true

  has_many :assets, class_name: "Image::Asset"

  delegate :content_type, to: :blob

  def readonly?
    !new_record?
  end

  def thumbnail
    crop_variant("#{Image::THUMBNAIL_WIDTH}x#{Image::THUMBNAIL_HEIGHT}")
  end

  def crop_variant(resize = "#{Image::WIDTH}x#{Image::HEIGHT}")
    options = { crop: "#{crop_width}x#{crop_height}+#{crop_x}+#{crop_y}" }
    options[:resize] = resize if resize
    blob.variant(options)
  end

  def bytes_for_asset(variant)
    case variant
    when "300"
      processed = crop_variant("300x200").processed
      processed.service.download(processed.key)
    when "960"
      processed = crop_variant("960x640").processed
      processed.service.download(processed.key)
    when "high_resolution"
      processed = crop_variant(nil).processed
      processed.service.download(processed.key)
    else
      raise RuntimeError, "Unsupported image revision variant #{variant}"
    end
  end

  def asset_url(variant)
    asset(variant)&.file_url
  end

  def asset(variant)
    assets.find { |v| v.variant == variant }
  end

  def at_exact_dimensions?
    width == Image::WIDTH && height == Image::HEIGHT
  end

  def ensure_assets
    known_variants = assets.map(&:variant)
    missing_variants = ASSET_VARIANTS - known_variants
    missing_variants.each do |variant|
      assets << Image::Asset.new(file_revision: self, variant: variant)
    end
  end
end
