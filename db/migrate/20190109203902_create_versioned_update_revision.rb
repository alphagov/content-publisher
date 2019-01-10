# frozen_string_literal: true

class CreateVersionedUpdateRevision < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_update_revisions do |t|
      t.string :update_type, null: false
      t.text :change_note
      t.datetime :created_at
      t.references :created_by,
                   foreign_key: { to_table: :users,
                                  on_delete: :nullify },
                   index: false,
                   null: true
    end
  end
end
