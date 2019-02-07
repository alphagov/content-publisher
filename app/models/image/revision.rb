# frozen_string_literal: true

# An image revision represents an edit of a particular image, it's data is
# stored across two associations: Image::FileRevision and
# Image::MetadataRevision.
#
# This is an immutable model
class Image::Revision < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true

  has_and_belongs_to_many :revisions

  belongs_to :image, class_name: "Image"

  belongs_to :file_revision, class_name: "Image::FileRevision"

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
end
