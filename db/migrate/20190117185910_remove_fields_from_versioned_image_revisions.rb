# frozen_string_literal: true

class RemoveFieldsFromVersionedImageRevisions < ActiveRecord::Migration[5.2]
  def up
    change_table :versioned_image_revisions, bulk: true do |t|
      t.remove_references :blob,
                          foreign_key: { to_table: :active_storage_blobs,
                                         on_delete: :restrict },
                          index: true,
                          null: false

      t.remove :width,
               :height,
               :crop_x,
               :crop_y,
               :crop_width,
               :crop_height,
               :filename,
               :caption,
               :alt_text,
               :credit
    end
  end

  def down
    change_table :versioned_image_revisions, bulk: true do |t|
      t.references :blob,
                   foreign_key: { to_table: :active_storage_blobs,
                                  on_delete: :restrict },
                   index: true,
                   null: false

      t.integer :width, null: false
      t.integer :height, null: false
      t.integer :crop_x, null: false
      t.integer :crop_y, null: false
      t.integer :crop_width, null: false
      t.integer :crop_height, null: false
      t.string :filename, null: false
      t.string :caption
      t.string :alt_text
      t.string :credit
    end
  end
end
