# frozen_string_literal: true

class RenameEditionStatusColumns < ActiveRecord::Migration[5.2]
  def change
    rename_column :versioned_timeline_entries, :edition_status_id, :status_id
  end
end
