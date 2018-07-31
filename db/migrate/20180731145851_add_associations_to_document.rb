# frozen_string_literal: true

class AddAssociationsToDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :associations, :json, default: {}
  end
end
