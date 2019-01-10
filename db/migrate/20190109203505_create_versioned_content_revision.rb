# frozen_string_literal: true

class CreateVersionedContentRevision < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_content_revisions do |t|
      t.string :title
      t.string :base_path
      t.text :summary
      t.json :contents, default: {}, null: false
      t.datetime :created_at
      t.references :created_by,
                   foreign_key: { to_table: :users,
                                  on_delete: :nullify },
                   index: false,
                   null: true
    end
  end
end
