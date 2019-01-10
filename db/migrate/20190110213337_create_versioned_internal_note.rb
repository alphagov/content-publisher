# frozen_string_literal: true

class CreateVersionedInternalNote < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_internal_notes do |t|
      t.text :body, null: false
      t.references :edition,
                   foreign_key: { on_delete: :cascade,
                                  to_table: :versioned_editions },
                   null: false
      t.references :created_by,
                   foreign_key: { on_delete: :nullify, to_table: :users },
                   null: true

      t.datetime :created_at
    end
  end
end
