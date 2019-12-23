# frozen_string_literal: true

class NamespaceWhitehallImport < ActiveRecord::Migration[6.0]
  def change
    rename_table :whitehall_imports, :whitehall_migration_document_imports
  end
end
