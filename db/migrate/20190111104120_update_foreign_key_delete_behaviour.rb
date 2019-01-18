# frozen_string_literal: true

class UpdateForeignKeyDeleteBehaviour < ActiveRecord::Migration[5.2]
  def change
    # In Rails 5.2 remove_foreign key is not reversible, this is fixed in later
    # Rails releases
    reversible do |dir|
      dir.up do
        remove_foreign_key :versioned_statuses,
                           column: :edition_id,
                           on_delete: :restrict
      end
      dir.down do
        add_foreign_key :versioned_statuses,
                        :versioned_editions,
                        column: :edition_id,
                        on_delete: :restrict
      end
    end

    add_foreign_key :versioned_statuses,
                    :versioned_editions,
                    column: :edition_id,
                    on_delete: :cascade

    reversible do |dir|
      dir.up do
        remove_foreign_key :versioned_edition_revisions,
                           column: :edition_id,
                           on_delete: :restrict
      end
      dir.down do
        add_foreign_key :versioned_edition_revisions,
                        :versioned_editions,
                        column: :edition_id,
                        on_delete: :restrict
      end
    end

    add_foreign_key :versioned_edition_revisions,
                    :versioned_editions,
                    column: :edition_id,
                    on_delete: :cascade

    reversible do |dir|
      dir.up do
        remove_foreign_key :versioned_edition_revisions,
                           column: :revision_id,
                           on_delete: :restrict
      end
      dir.down do
        add_foreign_key :versioned_edition_revisions,
                        :versioned_revisions,
                        column: :revision_id,
                        on_delete: :restrict
      end
    end

    add_foreign_key :versioned_edition_revisions,
                    :versioned_revisions,
                    column: :revision_id,
                    on_delete: :cascade
  end
end
