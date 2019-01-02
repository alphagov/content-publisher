# frozen_string_literal: true

module Versioned
  class ImageRevision < ApplicationRecord
    self.table_name = "versioned_image_revisions"

    WIDTH = 960
    HEIGHT = 640
    THUMBNAIL_WIDTH = 300
    THUMBNAIL_HEIGHT = 200

    belongs_to :blob, class_name: "ActiveStorage::Blob"

    # rubocop:disable Rails/InverseOf
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id
    # rubocop:enable Rails/InverseOf

    belongs_to :image,
               class_name: "Versioned::Image",
               foreign_key: :image_id,
               inverse_of: :image_revisions

    has_and_belongs_to_many :revisions,
                            class_name: "Versioned::Revision",
                            join_table: "versioned_revision_image_revisions"

    def readonly?
      !new_record?
    end

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
end
