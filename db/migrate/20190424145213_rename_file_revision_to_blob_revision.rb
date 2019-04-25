# frozen_string_literal: true

class RenameFileRevisionToBlobRevision < ActiveRecord::Migration[5.2]
  def change
    rename_table :file_attachment_file_revisions, :file_attachment_blob_revisions
    rename_table :image_file_revisions, :image_blob_revisions

    rename_column :image_revisions, :file_revision_id, :blob_revision_id
    rename_column :file_attachment_revisions, :file_revision_id, :blob_revision_id

    rename_column :image_assets, :file_revision_id, :blob_revision_id
    rename_column :file_attachment_assets, :file_revision_id, :blob_revision_id
  end
end
