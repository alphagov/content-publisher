# frozen_string_literal: true

class AddImportedFromToDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :imported_from, :string
  end
end
