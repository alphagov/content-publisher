# frozen_string_literal: true

class ChangeCurrentRevisionToRevision < ActiveRecord::Migration[5.2]
  def change
    remove_reference :versioned_editions,
                     :current_revision,
                     foreign_key: { to_table: :versioned_revisions, on_delete: :restrict },
                     index: true,
                     null: false
    add_reference :versioned_editions,
                  :revision,
                  foreign_key: { to_table: :versioned_revisions, on_delete: :restrict },
                  index: true,
                  null: false # rubocop:disable Rails/NotNullColumn
  end
end
