# frozen_string_literal: true

class AddWhitehallMigrationSubtypes < ActiveRecord::Migration[6.0]
  def change
    add_column :whitehall_migrations, :document_subtypes, :text, array: true
  end
end
