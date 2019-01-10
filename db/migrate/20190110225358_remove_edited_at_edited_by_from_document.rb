# frozen_string_literal: true

class RemoveEditedAtEditedByFromDocument < ActiveRecord::Migration[5.2]
  def up
    remove_column :versioned_documents, :last_edited_at
    remove_reference :versioned_documents, :last_edited_by
  end

  def down
    add_column :versioned_documents,
               :last_edited_at,
               :datetime,
               null: false # rubocop:disable Rails/NotNullColumn
    add_reference :versioned_documents,
                  :last_edited_by,
                  foreign_key: { to_table: :users, on_delete: :nullify },
                  index: true
  end
end
