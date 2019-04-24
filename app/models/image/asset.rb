# frozen_string_literal: true

# An Image::Asset is used to interface with Asset Manager to represent a
# file uploaded as part of an Image::Revision. It is used to track the state
# of the media on Asset Manager and it's url.
#
# This is a mutable model that is mutated when state changes on Asset Manager
class Image::Asset < ApplicationRecord
  belongs_to :blob_revision,
             class_name: "Image::BlobRevision",
             foreign_key: "file_revision_id"

  belongs_to :superseded_by,
             class_name: "Image::Asset",
             optional: true

  enum state: { absent: "absent",
                draft: "draft",
                live: "live",
                superseded: "superseded" }

  delegate :filename, :content_type, to: :blob_revision

  # TODO: Remove after breaking migration
  alias_attribute :blob_revision_id, :file_revision_id

  def asset_manager_id
    url_array = file_url.to_s.split("/")
    # https://github.com/alphagov/asset-manager#create-an-asset
    url_array[url_array.length - 2]
  end

  def bytes
    blob_revision.bytes_for_asset(variant)
  end
end
