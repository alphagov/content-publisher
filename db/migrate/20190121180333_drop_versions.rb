# frozen_string_literal: true

class DropVersions < ActiveRecord::Migration[5.2]
  def change
    drop_table :versions # rubocop:disable Rails/ReversibleMigration
  end
end
