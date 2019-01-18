# frozen_string_literal: true

class CreateVersionedRemoval < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_removals do |t|
      t.string :explanatory_note
      t.string :alternative_path
      t.boolean :redirect, default: false

      t.datetime :created_at, null: false
    end
  end
end
