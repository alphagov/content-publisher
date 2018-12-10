# frozen_string_literal: true

class AddCurrentRevisionToEditions < ActiveRecord::Migration[5.2]
  def change
    add_reference :versioned_editions,
                  :current_revision,
                  foreign_key: { to_table: :versioned_revisions, on_delete: :restrict },
                  index: true,
                  null: false # rubocop:disable Rails/NotNullColumn
  end
end
