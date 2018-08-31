# frozen_string_literal: true

class AddCreatorToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_reference :documents, :creator, foreign_key: { to_table: :users }
  end
end
