class CreateWhitehallImportedAssets < ActiveRecord::Migration[6.0]
  def change
    create_table :whitehall_imported_assets do |t|
      t.references :whitehall_import,
                   foreign_key: { to_table: :whitehall_imports,
                                  on_delete: :restrict },
                   index: true,
                   null: false

      # Asset must be one of FileAttachment or Image
      # @TODO - write a custom validator?
      t.references :file_attachment_revision,
                   foreign_key: { to_table: :file_attachment_revisions,
                                  on_delete: :cascade }
      t.references :image_revision,
                   foreign_key: { to_table: :image_revisions,
                                  on_delete: :cascade }

      t.string :original_asset_url, null: false
      t.string :variants, array: true, default: []
      t.string :state, null: false, default: "not_processed"
      t.text :error_log
      t.timestamps
    end
  end
end
