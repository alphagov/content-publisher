# frozen_string_literal: true

class Image < ApplicationRecord
  WIDTH = 960
  HEIGHT = 640
  THUMBNAIL_WIDTH = 300
  THUMBNAIL_HEIGHT = 200

  belongs_to :document
  belongs_to :blob, class_name: "ActiveStorage::Blob"

  validates :width,
            numericality: { only_integer: true, greater_than_or_equal_to: WIDTH }
  validates :height,
            numericality: { only_integer: true, greater_than_or_equal_to: HEIGHT }
  validates :crop_x,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :crop_y,
            numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :crop_width,
            numericality: { only_integer: true, greater_than_or_equal_to: WIDTH }
  validates :crop_height,
            numericality: { only_integer: true, greater_than_or_equal_to: HEIGHT }

  validates_with ImageAspectRatioValidator

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

  def cropped_file
    processed_image = thumbnail.processed
    image_bytes = processed_image.service.download(processed_image.key)
    AssetManagerFile.from_bytes(image_bytes, filename, blob.content_type, asset_manager_file_url)
  end

  # Used as a stand-in for a File / Rack::Multipart::UploadedFile object when
  # passed to GdsApi::AssetManager#create_asset. The interface is required for
  # uploading a file using the restclient we used in the backend.
  #
  # https://github.com/rest-client/rest-client/blob/master/lib/restclient/payload.rb#L181-L194
  #
  # This is done by delegating to 'io' which should implement the IO interface
  # (e.g. StringIO) and adds methods to return filename, content_type and path.
  class AssetManagerFile < SimpleDelegator
    attr_reader :original_filename, :content_type, :url

    def initialize(io, original_filename, content_type, url)
      super(io)
      @original_filename = original_filename
      @content_type = content_type
      @url = url
    end

    def self.from_bytes(content, original_filename, content_type, url)
      new(StringIO.new(content), original_filename, content_type, url)
    end

    def path
      original_filename
    end
  end
end
