# frozen_string_literal: true

# An image revision represents an edit of a particular image, it's data is
# stored across two associations: Image::BlobRevision and
# Image::MetadataRevision.
#
# This is an immutable model
class Image::Revision < ApplicationRecord
  COMPARISON_IGNORE_FIELDS = %w[id created_at created_by_id].freeze

  belongs_to :created_by, class_name: "User", optional: true

  has_and_belongs_to_many :revisions,
                          class_name: "::Revision",
                          foreign_key: "image_revision_id",
                          join_table: "revisions_image_revisions"

  belongs_to :image, class_name: "Image"

  belongs_to :blob_revision, class_name: "Image::BlobRevision"

  belongs_to :metadata_revision, class_name: "Image::MetadataRevision"

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
           :asset,
           :assets,
           :ensure_assets,
           :thumbnail,
           :crop_variant,
           :asset_url,
           :at_exact_dimensions?,
           to: :blob_revision

  def self.create_initial(image:,
                          crop_width:,
                          crop_height:,
                          crop_x:,
                          crop_y:,
                          filename:)
    blob_revision = Image::BlobRevision.new(crop_width: crop_width,
                                            crop_height: crop_height,
                                            crop_x: crop_x,
                                            crop_y: crop_y,
                                            filename: filename,
                                            created_by: image.created_by)
    blob_revision.ensure_assets

    create!(
      image: image,
      created_by: image.created_by,
      blob_revision: blob_revision,
      metadata_revision: Image::MetadataRevision.new(created_by: image.created_by),
    )
  end

  def readonly?
    !new_record?
  end
end
