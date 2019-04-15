# frozen_string_literal: true

class CreateFileAttachment < ActiveRecord::Migration[5.2]
  def change
    create_table :file_attachments do |t|
      t.datetime :created_at, null: false
      t.references :created_by,
                   foreign_key: { to_table: :users,
                                  on_delete: :restrict },
                   index: false
    end
  end
end
