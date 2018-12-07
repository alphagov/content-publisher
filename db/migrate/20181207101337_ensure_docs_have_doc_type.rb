# frozen_string_literal: true

class EnsureDocsHaveDocType < ActiveRecord::Migration[5.2]
  def change
    change_column :documents, :document_type_id, :string, null: false
  end
end
