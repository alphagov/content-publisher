# frozen_string_literal: true

class CreateFileAttachmentRevisions < ActiveRecord::Migration[5.2]
  def change
    create_table :file_attachment_revisions do |t|
      t.datetime :created_at, null: false
      t.references :created_by,
                   foreign_key: { to_table: :users,
                                  on_delete: :restrict },
                   index: false
      t.references :file_attachment,
                   foreign_key: { to_table: :file_attachments,
                                  on_delete: :restrict },
                   null: false
    end
  end
end
