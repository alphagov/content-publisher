# frozen_string_literal: true

class AddChangeNotesToDocuments < ActiveRecord::Migration[5.2]
  def change
    change_table :documents, bulk: true do |t|
      t.column :change_note, :text
      t.column :update_type, :string
    end
  end
end
