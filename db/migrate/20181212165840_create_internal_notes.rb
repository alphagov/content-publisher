# frozen_string_literal: true

class CreateInternalNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :internal_notes do |t|
      t.text :body, null: false
      t.references :document, foreign_key: { on_delete: :cascade }, null: false
      t.references :user, foreign_key: { on_delete: :nullify }
      t.references :timeline_entries, foreign_key: true, null: false

      t.timestamps
    end
  end
end
