# frozen_string_literal: true

class RemoveEditionsCurrentAndLiveIndexes < ActiveRecord::Migration[5.2]
  def change
    remove_index :editions, :current
    remove_index :editions, :live
  end
end
