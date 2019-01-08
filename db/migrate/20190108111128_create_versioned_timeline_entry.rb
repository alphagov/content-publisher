# frozen_string_literal: true

class CreateVersionedTimelineEntry < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_timeline_entries do |t|
      t.references :document,
                   foreign_key: { to_table: :versioned_documents,
                                  on_delete: :cascade },
                   index: true,
                   null: false

      t.references :edition,
                   foreign_key: { to_table: :versioned_editions,
                                  on_delete: :cascade },
                   index: true,
                   null: true

      t.references :revision,
                   foreign_key: { to_table: :versioned_revisions,
                                  on_delete: :nullify },
                   index: false,
                   null: true

      t.references :edition_status,
                   foreign_key: { to_table: :versioned_edition_statuses,
                                  on_delete: :nullify },
                   index: false,
                   null: true

      t.references :created_by,
                   foreign_key: { to_table: :users,
                                  on_delete: :nullify },
                   index: true,
                   null: true

      t.references :details, polymorphic: true

      t.datetime :created_at, null: false

      t.string :entry_type, null: false
    end
  end
end
