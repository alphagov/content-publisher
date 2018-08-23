# frozen_string_literal: true

class CreateImages < ActiveRecord::Migration[5.2]
  def change
    create_table :images do |t|
      t.references :document,
                   foreign_key: { on_delete: :cascade },
                   index: true,
                   null: false
      t.references :blob,
                   foreign_key: { to_table: :active_storage_blobs, on_delete: :cascade },
                   index: true,
                   null: false
      t.string :filename, null: false
      t.integer :width, null: false
      t.integer :height, null: false
      t.integer :crop_x, null: false
      t.integer :crop_y, null: false
      t.integer :crop_width, null: false
      t.integer :crop_height, null: false
      t.timestamps
    end
  end
end
