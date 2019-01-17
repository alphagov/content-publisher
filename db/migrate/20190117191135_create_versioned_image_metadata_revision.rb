# frozen_string_literal: true

class CreateVersionedImageMetadataRevision < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_image_metadata_revisions do |t|
      t.string :caption
      t.string :alt_text
      t.string :credit
      t.datetime :created_at
      t.references :created_by,
                   foreign_key: { to_table: :users,
                                  on_delete: :nullify },
                   index: false,
                   null: true
    end
  end
end
