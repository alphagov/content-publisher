# frozen_string_literal: true

class ReinstateVersionedEditionRevisions < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_edition_revisions do |t|
      t.references :edition,
                   foreign_key: { to_table: :versioned_editions,
                                  on_delete: :cascade },
                   index: true,
                   null: false
      t.references :revision,
                   foreign_key: { to_table: :versioned_revisions,
                                  on_delete: :cascade },
                   index: true,
                   null: false
      t.datetime :created_at, null: false
      t.index %i[edition_id revision_id], unique: true
    end
  end
end
