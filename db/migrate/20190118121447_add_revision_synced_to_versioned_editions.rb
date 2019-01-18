# frozen_string_literal: true

class AddRevisionSyncedToVersionedEditions < ActiveRecord::Migration[5.2]
  def change
    add_column :versioned_editions,
               :revision_synced,
               :boolean,
               null: false,
               default: false
  end
end
