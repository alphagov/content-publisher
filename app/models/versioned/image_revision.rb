# frozen_string_literal: true

module Versioned
  class ImageRevision < ApplicationRecord
    self.table_name = "versioned_image_revisions"

    WIDTH = 960
    HEIGHT = 640
    THUMBNAIL_WIDTH = 300
    THUMBNAIL_HEIGHT = 200

    # FIXME: we should see if these can be retina variants
    ASSET_MANAGER_VARIANTS = %w[300 960 high_resolution].freeze

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

    has_many :asset_manager_variants,
             class_name: "Versioned::AssetManagerImageVariant",
             inverse_of: :image_revision,
             dependent: :destroy

    has_many :asset_manager_files,
             through: :asset_manager_variants,
             source: :file

    def readonly?
      !new_record?
    end

    def build_next_revision(attributes, user, keep_variants: true)
      dup.tap do |revision|
        if keep_variants
          revision.asset_manager_variants = asset_manager_variants.map(&:dup)
        else
          revision.ensure_asset_manager_variants
        end
        revision.assign_attributes(attributes.merge(created_by: user))
      end
    end

    def ensure_asset_manager_variants
      known_variants = asset_manager_variants.map(&:variant)
      missing_variants = ASSET_MANAGER_VARIANTS - known_variants
      missing_variants.each do |variant|
        asset_manager_variants << AssetManagerImageVariant.build_with_file(variant)
      end
    end

    def bytes_for_asset_manager_variant(variant)
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

    def asset_manager_url(variant)
      asset_manager_variants.find { |v| v.variant == variant }&.file_url
    end

    def thumbnail
      crop_variant("#{THUMBNAIL_WIDTH}x#{THUMBNAIL_HEIGHT}")
    end

    def crop_variant(resize = "#{WIDTH}x#{HEIGHT}")
      options = { crop: "#{crop_width}x#{crop_height}+#{crop_x}+#{crop_y}" }
      options[:resize] = resize if resize
      blob.variant(options)
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
