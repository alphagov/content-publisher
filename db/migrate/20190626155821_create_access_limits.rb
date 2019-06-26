# frozen_string_literal: true

class CreateAccessLimits < ActiveRecord::Migration[5.2]
  def change
    create_table :access_limits do |t|
      t.datetime :created_at

      t.references :created_by,
                   foreign_key: { to_table: :users,
                                  on_delete: :restrict },
                   index: false

      t.references :edition,
                   foreign_key: { to_table: :editions,
                                  on_delete: :restrict },
                   null: false,
                   index: false

      t.references :revision_at_creation,
                   foreign_key: { to_table: :revisions,
                                  on_delete: :restrict },
                   null: false,
                   index: false

      t.string :limit_type, null: false
    end

    add_reference :editions,
                  :access_limit,
                  foreign_key: { on_delete: :restrict },
                  null: true,
                  index: true
  end
end
