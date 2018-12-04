# frozen_string_literal: true

class CreateRemovals < ActiveRecord::Migration[5.2]
  def change
    create_table :removals do |t|
      t.string :explanatory_note
      t.string :alternative_path
      t.boolean :redirect, default: false

      # Delete all removal entires if a timeline entry is deleted
      t.references :timeline_entries, foreign_key: { on_delete: :cascade }, null: false

      t.timestamps
    end
  end
end
