# frozen_string_literal: true

module Versioned
  # This represents a file that is stored on or should be stored on asset
  # manager
  class AssetManagerFile < ApplicationRecord
    self.table_name = "versioned_asset_manager_files"

    has_many :image_variants,
             class_name: "Versioned::AssetManagerImageVariant",
             inverse_of: :file,
             dependent: :restrict_with_exception

    has_many :image_revisions, through: :image_variants

    belongs_to :superseded_by,
               class_name: "Versioned::AssetManagerFile",
               inverse_of: :supersedes,
               optional: true

    has_many :supersedes,
             class_name: "Versioned::AssetManagerFile",
             foreign_key: :superseded_by_id,
             inverse_of: :superseded_by,
             dependent: :nullify

    enum state: { absent: "absent",
                  draft: "draft",
                  live: "live",
                  superseded: "superseded" }

    def asset_manager_id
      url_array = file_url.to_s.split("/")
      # https://github.com/alphagov/asset-manager#create-an-asset
      url_array[url_array.length - 2]
    end
  end
end
