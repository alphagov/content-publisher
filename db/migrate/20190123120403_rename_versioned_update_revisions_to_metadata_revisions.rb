# frozen_string_literal: true

class RenameVersionedUpdateRevisionsToMetadataRevisions < ActiveRecord::Migration[5.2]
  def change
    rename_table :versioned_update_revisions, :metadata_revisions
    rename_column :versioned_revisions, :update_revision_id, :metadata_revision_id
  end
end
