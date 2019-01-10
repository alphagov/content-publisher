# frozen_string_literal: true

class CreateVersionedTagsRevision < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_tags_revisions do |t|
      t.json :tags, default: {}, null: false
      t.datetime :created_at
      t.references :created_by,
                   foreign_key: { to_table: :users,
                                  on_delete: :nullify },
                   index: false,
                   null: true
    end
  end
end
