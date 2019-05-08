# frozen_string_literal: true

class CreateVersionedImageAsset < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_image_assets do |t|
      t.references :file_revision,
                   foreign_key: { to_table: :versioned_image_file_revisions,
                                  on_delete: :cascade },
                   index: true,
                   null: false

      t.references :superseded_by,
                   foreign_key: { to_table: :versioned_image_assets,
                                on_delete: :nullify },
                   index: false,
                   null: true

      t.string :variant, null: false
      t.string :file_url
      t.string :state, default: "absent", null: false
      t.timestamps

      t.index :file_url, unique: true
      t.index %i[file_revision_id variant],
              unique: true,
              name: "index_versioned_image_asset_unique_variant"
    end
  end
end
