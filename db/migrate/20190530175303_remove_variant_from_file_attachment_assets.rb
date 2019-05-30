# frozen_string_literal: true

class RemoveVariantFromFileAttachmentAssets < ActiveRecord::Migration[5.2]
  def change
    remove_index :file_attachment_assets,
                 column: %i[blob_revision_id variant],
                 unique: true
    remove_column :file_attachment_assets,
                  :variant,
                  :string,
                  default: "file",
                  null: false

    remove_index :file_attachment_assets, :blob_revision_id
    add_index :file_attachment_assets, :blob_revision_id, unique: true
  end
end
