# frozen_string_literal: true

class AddIntegrityCheckProblemsToWhitehallDocumentMigration < ActiveRecord::Migration[6.0]
  def change
    change_table :whitehall_migration_document_imports, bulk: true do |t|
      t.string :integrity_check_problems, array: true, default: [], null: false
      t.json :integrity_check_proposed_payload, default: "{}", null: false
    end
  end
end
