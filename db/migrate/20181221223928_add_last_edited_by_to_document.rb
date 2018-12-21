# frozen_string_literal: true

class AddLastEditedByToDocument < ActiveRecord::Migration[5.2]
  def change
    add_reference :versioned_documents,
                  :last_edited_by,
                  foreign_key: { to_table: :users, on_delete: :nullify },
                  index: true
  end
end
