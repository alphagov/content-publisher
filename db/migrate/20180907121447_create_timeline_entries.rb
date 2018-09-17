# frozen_string_literal: true

class CreateTimelineEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :timeline_entries do |t|
      t.string :entry_type, null: false

      # Delete all timeline_entries if a document is deleted
      t.references :document, foreign_key: { on_delete: :cascade }, null: false

      # Don't allow users to be deleted if they're related to a timeline entry
      t.references :user, foreign_key: { on_delete: :restrict }

      t.timestamps
    end
  end
end
