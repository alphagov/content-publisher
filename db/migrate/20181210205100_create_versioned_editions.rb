# frozen_string_literal: true

class CreateVersionedEditions < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_editions do |t|
      t.integer :number, null: false
      t.datetime :last_edited_at
      t.timestamps

      t.references :document,
                   foreign_key: { to_table: :versioned_documents, on_delete: :restrict },
                   index: true,
                   null: false

      t.references :created_by,
                   foreign_key: { to_table: :users, on_delete: :restrict },
                   index: true
    end
  end
end
