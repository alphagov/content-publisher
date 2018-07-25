# frozen_string_literal: true

class AddBasePathToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :base_path, :string
  end
end
