# frozen_string_literal: true

class NullifyUserForTimelineEntry < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key "timeline_entries", "users"
    add_foreign_key "timeline_entries", "users", on_delete: :nullify
  end

  def down
    remove_foreign_key "timeline_entries", "users"
    add_foreign_key "timeline_entries", "users", on_delete: :restrict
  end
end
