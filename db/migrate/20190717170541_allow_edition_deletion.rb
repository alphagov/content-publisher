# frozen_string_literal: true

class AllowEditionDeletion < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :access_limits, :editions
    add_foreign_key :access_limits,
                    :editions,
                    on_delete: :cascade

    remove_foreign_key :editions_revisions, :editions
    add_foreign_key :editions_revisions,
                    :editions,
                    on_delete: :cascade

    remove_foreign_key :statuses, :editions
    add_foreign_key :statuses,
                    :editions,
                    on_delete: :cascade

    remove_foreign_key :revisions_statuses, :statuses
    add_foreign_key :revisions_statuses,
                    :statuses,
                    on_delete: :cascade

    remove_foreign_key :internal_notes, :editions
    add_foreign_key :internal_notes,
                    :editions,
                    on_delete: :cascade

    remove_foreign_key :timeline_entries, :editions
    add_foreign_key :timeline_entries,
                    :editions,
                    on_delete: :cascade
  end

  def down
    remove_foreign_key :access_limits, :editions
    add_foreign_key :access_limits,
                    :editions,
                    on_delete: :restrict

    remove_foreign_key :editions_revisions, :editions
    add_foreign_key :editions_revisions,
                    :editions,
                    on_delete: :restrict

    remove_foreign_key :statuses, :editions
    add_foreign_key :statuses,
                    :editions,
                    on_delete: :restrict

    remove_foreign_key :revisions_statuses, :statuses
    add_foreign_key :revisions_statuses,
                    :statuses,
                    on_delete: :restrict

    remove_foreign_key :internal_notes, :editions
    add_foreign_key :internal_notes,
                    :editions,
                    on_delete: :restrict

    remove_foreign_key :timeline_entries, :editions
    add_foreign_key :timeline_entries,
                    :editions,
                    on_delete: :restrict
  end
end
