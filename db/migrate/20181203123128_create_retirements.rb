# frozen_string_literal: true

class CreateRetirements < ActiveRecord::Migration[5.2]
  def change
    create_table :retirements do |t|
      t.string :explanatory_note

      # Delete all retirement entires if a timeline entry is deleted
      t.references :timeline_entries, foreign_key: { on_delete: :cascade }, null: false

      t.timestamps
    end
  end
end
