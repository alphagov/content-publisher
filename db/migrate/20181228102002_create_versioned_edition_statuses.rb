# frozen_string_literal: true

class CreateVersionedEditionStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_edition_statuses do |t|
      t.string :user_facing_state, null: false
      t.string :publishing_api_sync, null: false
      t.references :revision_at_creation,
                   foreign_key: { to_table: :versioned_revisions,
                                  on_delete: :restrict },
                   index: true,
                   null: false
      t.references :edition,
                   foreign_key: { to_table: :versioned_editions,
                                  on_delete: :restrict },
                   index: true
      t.references :created_by,
                   foreign_key: { to_table: :users,
                                  on_delete: :nullify },
                   index: true

      t.timestamps

      t.index :user_facing_state
    end
  end
end
