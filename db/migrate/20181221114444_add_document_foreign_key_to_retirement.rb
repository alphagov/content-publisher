# frozen_string_literal: true

class AddDocumentForeignKeyToRetirement < ActiveRecord::Migration[5.2]
  def change
    add_column :retirements, :document_id, :bigint
    add_foreign_key :retirements, :documents
  end
end
