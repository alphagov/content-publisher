class RenameBodyOnTimelineEntryWhitehallImportedEntriesToContents < ActiveRecord::Migration[6.0]
  def change
    rename_column :timeline_entry_whitehall_imported_entries, :body, :contents
  end
end
