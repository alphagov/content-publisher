# frozen_string_literal: true

class AddCurrentAndLiveIndexesToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_index :versioned_editions, :current
    add_index :versioned_editions, :live
  end
end
