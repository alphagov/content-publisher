# frozen_string_literal: true

class RenameImageAssetsFileImageVariantIndex < ActiveRecord::Migration[5.2]
  def change
    rename_index :image_assets, "index_versioned_image_asset_unique_variant", "index_image_asset_unique_variant"
  end
end
