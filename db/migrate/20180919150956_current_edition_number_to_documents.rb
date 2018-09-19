# frozen_string_literal: true

class CurrentEditionNumberToDocuments < ActiveRecord::Migration[5.2]
  def up
    execute "TRUNCATE documents CASCADE"
    add_column :documents, :current_edition_number, :integer, null: false # rubocop:disable Rails/NotNullColumn
    add_column :timeline_entries, :edition_number, :integer, null: false # rubocop:disable Rails/NotNullColumn
  end

  def down
    remove_column :documents, :current_edition_number
    remove_column :timeline_entries, :edition_number
  end
end
