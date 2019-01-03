# frozen_string_literal: true

class CreateVersionedAssetManagerImageVariants < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_asset_manager_image_variants do |t|
      t.references :image_revision,
                   foreign_key: { to_table: :versioned_image_revisions,
                                  on_delete: :cascade },
                   index: false,
                   null: false

      t.references :asset_manager_file,
                   foreign_key: { to_table: :versioned_asset_manager_files,
                                  on_delete: :restrict },
                   index: false,
                   null: false

      t.string :variant, null: false

      t.datetime :created_at, null: false

      t.index %i[image_revision_id asset_manager_file_id],
              unique: true,
              name: "index_image_revision_asset_manager_variant_ids"

      t.index %i[image_revision_id variant],
              unique: true,
              name: "index_image_revision_asset_manager_variant_unique_variant"
    end
  end
end
