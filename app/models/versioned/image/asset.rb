# frozen_string_literal: true

module Versioned
  # An Image::Asset is used to interface with Asset Manager to represent a
  # file uploaded as part of an Image::Revision. It is used to track the state
  # of the media on Asset Manager and it's url.
  #
  # This is a mutable model that is mutated when state changes on Asset Manager
  class Image::Asset < ApplicationRecord
    self.table_name = "versioned_image_assets"

    belongs_to :file_revision,
               class_name: "Versioned::Image::FileRevision",
               foreign_key: :file_revision_id,
               inverse_of: :assets

    belongs_to :superseded_by,
               class_name: "Versioned::Image::Asset",
               inverse_of: :supersedes,
               optional: true

    has_many :supersedes,
             class_name: "Versioned::Image::Asset",
             foreign_key: :superseded_by_id,
             inverse_of: :superseded_by,
             dependent: :nullify

    enum state: { absent: "absent",
                  draft: "draft",
                  live: "live",
                  superseded: "superseded" }

    delegate :filename, :content_type, to: :file_revision

    def asset_manager_id
      url_array = file_url.to_s.split("/")
      # https://github.com/alphagov/asset-manager#create-an-asset
      url_array[url_array.length - 2]
    end

    def bytes
      file_revision.bytes_for_asset(variant)
    end
  end
end
