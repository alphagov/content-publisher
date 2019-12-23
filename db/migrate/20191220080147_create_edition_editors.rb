# frozen_string_literal: true

class CreateEditionEditors < ActiveRecord::Migration[6.0]
  def change
    create_table :edition_editors do |t|
      t.references :edition,
                   foreign_key: { to_table: :editions, on_delete: :restrict },
                   index: true,
                   null: false

      t.references :user,
                   foreign_key: { to_table: :users, on_delete: :restrict },
                   index: true,
                   null: false

      t.index %i[edition_id user_id], unique: true

      t.datetime :created_at, null: false
    end
  end
end
