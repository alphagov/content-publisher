# frozen_string_literal: true

class RemoveAssetManagerTables < ActiveRecord::Migration[5.2]
  def up
    drop_table :versioned_asset_manager_image_variants
    drop_table :versioned_asset_manager_files
  end

  def down
    create_table :versioned_asset_manager_files do |t|
      t.string :file_url
      t.string :state, null: false, default: "absent"
      t.references :superseded_by,
                   foreign_key: { to_table: :versioned_asset_manager_files,
                                  on_delete: :nullify },
                   index: false,
                   null: true
      t.timestamps

      t.index :file_url, unique: true
    end

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
