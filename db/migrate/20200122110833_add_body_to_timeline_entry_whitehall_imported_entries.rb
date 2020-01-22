# frozen_string_literal: true

class AddBodyToTimelineEntryWhitehallImportedEntries < ActiveRecord::Migration[6.0]
  def change
    add_column :timeline_entry_whitehall_imported_entries, :body, :json, default: "{}", null: false
  end
end
