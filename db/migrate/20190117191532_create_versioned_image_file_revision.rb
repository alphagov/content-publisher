# frozen_string_literal: true

class CreateVersionedImageFileRevision < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_image_file_revisions do |t|
      t.references :blob,
                   foreign_key: { to_table: :active_storage_blobs,
                                  on_delete: :restrict },
                   index: true,
                   null: false
      t.references :created_by,
                   foreign_key: { to_table: :users,
                                  on_delete: :nullify },
                   index: false,
                   null: true
      t.integer :width, null: false
      t.integer :height, null: false
      t.integer :crop_x, null: false
      t.integer :crop_y, null: false
      t.integer :crop_width, null: false
      t.integer :crop_height, null: false
      t.string :filename, null: false
      t.datetime :created_at
    end
  end
end
