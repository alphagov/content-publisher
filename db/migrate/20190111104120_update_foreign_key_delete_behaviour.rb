# frozen_string_literal: true

class UpdateForeignKeyDeleteBehaviour < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :versioned_statuses, column: :edition_id

    add_foreign_key :versioned_statuses,
                    :versioned_editions,
                    column: :edition_id,
                    on_delete: :cascade

    remove_foreign_key :versioned_edition_revisions, column: :edition_id

    add_foreign_key :versioned_edition_revisions,
                    :versioned_editions,
                    column: :edition_id,
                    on_delete: :cascade

    remove_foreign_key :versioned_edition_revisions, column: :revision_id

    add_foreign_key :versioned_edition_revisions,
                    :versioned_revisions,
                    column: :revision_id,
                    on_delete: :cascade
  end

  def down
    remove_foreign_key :versioned_statuses, column: :edition_id

    add_foreign_key :versioned_statuses,
                    :versioned_editions,
                    column: :edition_id,
                    on_delete: :restrict

    remove_foreign_key :versioned_edition_revisions, column: :edition_id

    add_foreign_key :versioned_edition_revisions,
                    :versioned_editions,
                    column: :edition_id,
                    on_delete: :restrict

    remove_foreign_key :versioned_edition_revisions, column: :revision_id

    add_foreign_key :versioned_edition_revisions,
                    :versioned_revisions,
                    column: :revision_id,
                    on_delete: :restrict
  end
end
