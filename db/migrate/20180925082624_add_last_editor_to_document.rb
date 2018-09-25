# frozen_string_literal: true

class AddLastEditorToDocument < ActiveRecord::Migration[5.2]
  def change
    add_reference :documents, :last_editor, foreign_key: { to_table: :users }
  end
end
