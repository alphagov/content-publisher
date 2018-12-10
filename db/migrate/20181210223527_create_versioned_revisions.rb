# frozen_string_literal: true

class CreateVersionedRevisions < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_revisions do |t|
      t.string :title
      t.string :base_path
      t.text :summary
      t.json :contents, default: {}, null: false
      t.json :tags, default: {}, null: false
      t.text :change_note
      t.string :update_type

      t.references :created_by,
                   foreign_key: { to_table: :users, on_delete: :restrict },
                   index: true

      t.datetime :created_at, null: false
    end
  end
end
