# frozen_string_literal: true

class CreateWhitehallImportedAssets < ActiveRecord::Migration[6.0]
  def change
    create_table :whitehall_imported_assets do |t|
      t.references :whitehall_import,
                   foreign_key: { to_table: :whitehall_imports,
                                  on_delete: :restrict },
                   index: true,
                   null: false
      t.references :file_attachment_revision,
                   foreign_key: { to_table: :file_attachment_revisions,
                                  on_delete: :restrict }
      t.references :image_revision,
                   foreign_key: { to_table: :image_revisions,
                                  on_delete: :restrict }

      t.string :original_asset_url, null: false
      t.json :variants, default: {}, null: false
      t.string :state, null: false, default: "not_processed"
      t.text :error_message
      t.timestamps
    end
  end
end
