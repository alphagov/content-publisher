class AddWhitehallMigrationNullConstraintToDocumentImports < ActiveRecord::Migration[6.0]
  def change
    change_column_null :whitehall_migration_document_imports, :whitehall_migration_id, false
  end
end
