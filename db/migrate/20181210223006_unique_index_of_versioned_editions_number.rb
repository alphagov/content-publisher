# frozen_string_literal: true

class UniqueIndexOfVersionedEditionsNumber < ActiveRecord::Migration[5.2]
  def change
    add_index :versioned_editions, %i[document_id number], unique: true
  end
end
