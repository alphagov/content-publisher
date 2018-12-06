# frozen_string_literal: true

class RenameDocumentTypeId < ActiveRecord::Migration[5.2]
  def change
    rename_column :documents, :document_type, :document_type_id
  end
end
