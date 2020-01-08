# frozen_string_literal: true

class CascadeEditionEditorDeletion < ActiveRecord::Migration[6.0]
  def up
    remove_foreign_key :edition_editors, :editions
    add_foreign_key :edition_editors, :editions, on_delete: :cascade
  end

  def down
    remove_foreign_key :edition_editors, :editions
    add_foreign_key :edition_editors, :editions, on_delete: :restrict
  end
end
