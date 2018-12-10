# frozen_string_literal: true

class AddCurrentAndLiveFlagsToVersionedEditions < ActiveRecord::Migration[5.2]
  def change
    change_table :versioned_editions, bulk: true do |t|
      t.column :current, :boolean, null: false, default: false
      t.column :live, :boolean, null: false, default: false
      t.index %i[document_id current], unique: true, where: "current = true"
      t.index %i[document_id live], unique: true, where: "live = true"
    end
  end
end
