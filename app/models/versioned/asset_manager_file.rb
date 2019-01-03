# frozen_string_literal: true

module Versioned
  class AssetManagerFile < ApplicationRecord
    self.table_name = "versioned_asset_manager_files"

    has_many :image_variants,
             class_name: "Versioned::AssetManagerImageVariant",
             inverse_of: :file,
             dependent: :restrict_with_exception

    has_many :image_revisions, through: :image_variants

    enum state: { absent: "absent",
                  draft: "draft",
                  live: "live" }

    def asset_manager_id
      url_array = file_url.to_s.split("/")
      # https://github.com/alphagov/asset-manager#create-an-asset
      url_array[url_array.length - 2]
    end
  end
end
