# frozen_string_literal: true

class RemoveVersionedEditionsCurrentAndLiveIndexes < ActiveRecord::Migration[5.2]
  def change
    remove_index :versioned_editions, :current
    remove_index :versioned_editions, :live
  end
end
