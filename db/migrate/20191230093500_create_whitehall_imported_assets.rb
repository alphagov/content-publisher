# frozen_string_literal: true

class CreateWhitehallImportedAssets < ActiveRecord::Migration[6.0]
  def change
    create_table :whitehall_migration_asset_imports do |t|
      t.references :document_import,
                   foreign_key: { to_table: :whitehall_migration_document_imports,
                                  on_delete: :restrict },
                   index: { name: :index_whitehall_migration_asset_on_document },
                   null: false
      t.references :file_attachment_revision,
                   foreign_key: { to_table: :file_attachment_revisions,
                                  on_delete: :restrict },
                   index: false
      t.references :image_revision,
                   foreign_key: { to_table: :image_revisions,
                                  on_delete: :restrict },
                   index: false

      t.string :original_asset_url, null: false
      t.string :state, null: false, default: "pending"
      t.string :variant
      t.text :error_message
      t.timestamps
    end
  end
end
