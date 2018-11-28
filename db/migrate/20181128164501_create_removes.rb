# frozen_string_literal: true

class CreateRemoves < ActiveRecord::Migration[5.2]
  def change
    create_table :removes do |t|
      t.string :explanatory_note
      t.string :alternative_path
      t.boolean :redirect, default: false

      # Delete all removal entires if a timeline entry is deleted
      t.references :timeline_entries, foreign_key: { on_delete: :cascade }, null: false

      t.timestamps
    end
  end
end
