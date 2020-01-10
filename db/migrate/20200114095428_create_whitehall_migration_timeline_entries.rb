# frozen_string_literal: true

class CreateWhitehallMigrationTimelineEntries < ActiveRecord::Migration[6.0]
  def change
    create_table :timeline_entry_whitehall_imported_entries do |t|
      t.string "entry_type", null: false
      t.datetime "created_at"
    end
  end
end
