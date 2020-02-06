# frozen_string_literal: true

class RemoveNullConstraintsFromWhitehallMigrations < ActiveRecord::Migration[6.0]
  def change
    change_column_null :whitehall_migrations, :document_type, true
    change_column_null :whitehall_migrations, :organisation_content_id, true
  end
end
