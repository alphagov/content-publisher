# frozen_string_literal: true

class CreateVersionedImageTables < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_images do |t|
      t.references :created_by,
                   foreign_key: { to_table: :users, on_delete: :nullify },
                   index: false
      t.datetime :created_at, null: false
    end

    create_table :versioned_image_revisions do |t|
      t.references :blob,
                   foreign_key: { to_table: :active_storage_blobs,
                                  on_delete: :restrict },
                   index: true,
                   null: false
      t.references :image,
                   foreign_key: { to_table: :versioned_images,
                                  on_delete: :restrict },
                   index: true,
                   null: false
      t.references :created_by,
                   foreign_key: { to_table: :users, on_delete: :nullify },
                   index: false
      t.string :filename, null: false
      t.integer :width, null: false
      t.integer :height, null: false
      t.integer :crop_x, null: false
      t.integer :crop_y, null: false
      t.integer :crop_width, null: false
      t.integer :crop_height, null: false
      t.string :caption
      t.string :alt_text
      t.string :credit
      t.datetime :created_at, null: false
    end

    create_table :versioned_revision_image_revisions do |t|
      t.references :image_revision,
                   foreign_key: { to_table: :versioned_image_revisions,
                                  on_delete: :restrict },
                   index: true,
                   null: false
      t.references :revision,
                   foreign_key: { to_table: :versioned_revisions,
                                  on_delete: :restrict },
                   index: true,
                   null: false
      t.datetime :created_at, null: false
    end

    add_reference :versioned_revisions,
                  :lead_image_revision,
                  foreign_key: { to_table: :versioned_image_revisions,
                                 on_delete: :restrict },
                  index: true
  end
end
