# frozen_string_literal: true

class RemoveNotNullFromDocumentImport < ActiveRecord::Migration[6.0]
  def change
    change_column_null :whitehall_migration_document_imports, :payload, true
    change_column_null :whitehall_migration_document_imports, :content_id, true
  end
end
