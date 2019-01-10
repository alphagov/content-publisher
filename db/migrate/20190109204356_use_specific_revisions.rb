# frozen_string_literal: true

class UseSpecificRevisions < ActiveRecord::Migration[5.2]
  def change
    reversible do |dir|
      dir.up do
        change_table :versioned_revisions, bulk: true do |t|
          t.remove :title, :base_path, :summary, :contents, :tags, :change_note, :update_type
        end
      end

      dir.down do
        change_table :versioned_revisions, bulk: true do |t|
          t.string :title
          t.string :base_path
          t.text :summary
          t.json :contents, default: {}, null: false
          t.json :tags, default: {}, null: false
          t.text :change_note
          t.string :update_type, null: false
        end
      end
    end

    change_table :versioned_revisions, bulk: true do |t|
      t.references :content_revision,
                   foreign_key: { to_table: :versioned_content_revisions,
                                  on_delete: :restrict },
                   index: true,
                   null: false
      t.references :update_revision,
                   foreign_key: { to_table: :versioned_update_revisions,
                                  on_delete: :restrict },
                   index: true,
                   null: false
      t.references :tags_revision,
                   foreign_key: { to_table: :versioned_tags_revisions,
                                  on_delete: :restrict },
                   index: true,
                   null: false
    end
  end
end
