# frozen_string_literal: true

class AddFileAttachmentFileRevision < ActiveRecord::Migration[5.2]
  def change
    create_table :file_attachment_file_revisions do |t|
      t.references :blob,
                   foreign_key: { to_table: :active_storage_blobs,
                                  on_delete: :restrict },
                   index: true,
                   null: false
      t.references :created_by,
                   foreign_key: { to_table: :users,
                                  on_delete: :restrict },
                   index: false
      t.string :filename, null: false
      t.datetime :created_at, null: false
    end
  end
end
