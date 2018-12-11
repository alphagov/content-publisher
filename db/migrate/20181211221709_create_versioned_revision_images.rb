# frozen_string_literal: true

class CreateVersionedRevisionImages < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_revision_images do |t|
      t.references :image,
                   foreign_key: { to_table: :versioned_images, on_delete: :restrict },
                   index: true,
                   null: false
      t.references :revision,
                   foreign_key: { to_table: :versioned_revisions, on_delete: :restrict },
                   index: true,
                   null: false
      t.datetime :created_at, null: false
    end
  end
end
