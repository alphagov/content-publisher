# frozen_string_literal: true

class DeletePreVersioningTables < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :documents, :images
    remove_foreign_key :documents, :users
    remove_foreign_key :images, :active_storage_blobs
    remove_foreign_key :images, :documents
    remove_foreign_key :internal_notes, :timeline_entries
    remove_foreign_key :internal_notes, :documents
    remove_foreign_key :removals, :timeline_entries
    remove_foreign_key :retirements, :timeline_entries
    remove_foreign_key :timeline_entries, :documents
    remove_foreign_key :timeline_entries, :users

    drop_table :documents # rubocop:disable Rails/ReversibleMigration
    drop_table :images # rubocop:disable Rails/ReversibleMigration
    drop_table :internal_notes # rubocop:disable Rails/ReversibleMigration
    drop_table :removals # rubocop:disable Rails/ReversibleMigration
    drop_table :retirements # rubocop:disable Rails/ReversibleMigration
    drop_table :timeline_entries # rubocop:disable Rails/ReversibleMigration
  end
end
