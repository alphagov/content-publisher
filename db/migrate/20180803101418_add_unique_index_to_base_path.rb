# frozen_string_literal: true

class AddUniqueIndexToBasePath < ActiveRecord::Migration[5.2]
  def change
    add_index :documents, :base_path, unique: true
  end
end
