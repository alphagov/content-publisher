# frozen_string_literal: true

class CreateFileAttachmentAsset < ActiveRecord::Migration[5.2]
  def change
    create_table :file_attachment_assets do |t|
      t.references :file_revision,
                   foreign_key: { to_table: :file_attachment_file_revisions,
                                  on_delete: :restrict },
                   index: true,
                   null: false

      t.string :variant, default: "file", null: false
      t.string :file_url
      t.string :state, default: "absent", null: false
      t.timestamps

      t.index :file_url, unique: true
      t.index %i[file_revision_id variant],
              unique: true
    end
  end
end
