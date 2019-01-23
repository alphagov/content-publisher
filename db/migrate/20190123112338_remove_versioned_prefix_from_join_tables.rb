# frozen_string_literal: true

class RemoveVersionedPrefixFromJoinTables < ActiveRecord::Migration[5.2]
  def change
    rename_table :versioned_edition_revisions, :editions_revisions
    rename_table :versioned_revision_image_revisions, :revisions_image_revisions
    rename_table :versioned_revision_statuses, :revisions_statuses
  end
end
