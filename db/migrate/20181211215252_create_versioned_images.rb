# frozen_string_literal: true

class CreateVersionedImages < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_images do |t|
      t.references :blob,
                   foreign_key: { to_table: :active_storage_blobs, on_delete: :restrict },
                   index: true,
                   null: false
      t.string :filename, null: false
      t.integer :width, null: false
      t.integer :height, null: false
      t.integer :crop_x, null: false
      t.integer :crop_y, null: false
      t.integer :crop_width, null: false
      t.integer :crop_height, null: false
      t.string "caption"
      t.string "alt_text"
      t.string "credit"
      t.datetime :created_at, null: false
    end
  end
end
