# frozen_string_literal: true

class CreateVersionedRevisionStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_revision_statuses do |t|
      t.references :revision,
                   foreign_key: { to_table: :versioned_revisions,
                                  on_delete: :cascade },
                   index: true,
                   null: false
      t.references :status,
                   foreign_key: { to_table: :versioned_statuses,
                                  on_delete: :cascade },
                   index: true,
                   null: false

      t.datetime :created_at, null: false

      t.index %i[revision_id status_id], unique: true
    end
  end
end
