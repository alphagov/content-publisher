# frozen_string_literal: true

module Versioned
  # An image revision represents an edit of a particular image, it's data is
  # stored across two associations: Image::FileRevision and
  # Image::MetadataRevision.
  #
  # This is an immutable model
  class Image::Revision < ApplicationRecord
    self.table_name = "versioned_image_revisions"

    COMPARISON_IGNORE_FIELDS = %w[id created_at created_by_id].freeze

    # rubocop:disable Rails/InverseOf
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id
    # rubocop:enable Rails/InverseOf

    has_and_belongs_to_many :revisions,
                            foreign_key: "image_revision_id",
                            class_name: "Versioned::Revision",
                            join_table: "versioned_revision_image_revisions"

    belongs_to :image,
               class_name: "Versioned::Image",
               foreign_key: :image_id,
               inverse_of: :image_revisions

    belongs_to :file_revision,
               class_name: "Versioned::Image::FileRevision",
               foreign_key: :file_revision_id,
               inverse_of: :revisions

    belongs_to :metadata_revision,
               class_name: "Versioned::Image::MetadataRevision",
               foreign_key: :metadata_revision_id,
               inverse_of: :revisions

    delegate :alt_text,
             :caption,
             :credit,
             to: :metadata_revision

    delegate :blob,
             :filename,
             :content_type,
             :width,
             :height,
             :crop_x,
             :crop_y,
             :crop_width,
             :crop_height,
             :assets,
             :ensure_assets,
             :thumbnail,
             :crop_variant,
             :asset_url,
             :at_exact_dimensions?,
             to: :file_revision

    def self.create_initial(image:,
                            crop_width:,
                            crop_height:,
                            crop_x:,
                            crop_y:,
                            filename:)
      file_revision = Image::FileRevision.new(crop_width: crop_width,
                                              crop_height: crop_height,
                                              crop_x: crop_x,
                                              crop_y: crop_y,
                                              filename: filename,
                                              created_by: image.created_by)
      file_revision.ensure_assets

      create!(
        image: image,
        created_by: image.created_by,
        file_revision: file_revision,
        metadata_revision: Image::MetadataRevision.new(created_by: image.created_by),
      )
    end

    def readonly?
      !new_record?
    end

    def build_revision_update(attributes, user)
      BuildRevisionUpdate.new(attributes, user, self).build
    end

    def different_to?(other_revision)
      raise "Must compare with a persisted record" if other_revision.new_record?

      other_attributes = other_revision.attributes.except(*COMPARISON_IGNORE_FIELDS)
      attributes.except(*COMPARISON_IGNORE_FIELDS) != other_attributes
    end

    class BuildRevisionUpdate
      attr_reader :attributes, :user, :preceding_revision

      def initialize(attributes, user, preceding_revision)
        @attributes = HashWithIndifferentAccess.new(attributes)
        @user = user
        @preceding_revision = preceding_revision
      end

      def build
        # we use dup to shallow clone the record which won't work unless data
        # is persisted (clone would be approriate) - it seems unlikely this
        # would need to be run with something unpersisted
        raise "Can't update from an unpersisted record" if preceding_revision.new_record?

        next_revision = preceding_revision.dup
        file_revision(next_revision)
        metadata_revision(next_revision)

        if next_revision.different_to?(preceding_revision)
          next_revision.tap { |r| r.created_by = user }
        else
          preceding_revision
        end
      end

    private

      def file_revision(next_revision)
        file_attributes = attributes.slice(:filename,
                                           :crop_x,
                                           :crop_y,
                                           :crop_width,
                                           :crop_height)
        unless file_attributes.empty?
          revision = preceding_revision.file_revision
                                       .build_revision_update(file_attributes, user)
          next_revision.file_revision = revision
        end
      end

      def metadata_revision(next_revision)
        metadata = attributes.slice(:alt_text, :caption, :credit)
        unless metadata.empty?
          revision = next_revision.metadata_revision
                                  .build_revision_update(metadata, user)
          next_revision.metadata_revision = revision
        end
      end
    end
  end
end
