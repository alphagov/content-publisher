# frozen_string_literal: true

class RemoveVersionedPrefixFromTables < ActiveRecord::Migration[5.2]
  def change
    rename_table :versioned_content_revisions, :content_revisions
    rename_table :versioned_documents, :documents
    rename_table :versioned_editions, :editions
    rename_table :versioned_timeline_entries, :timeline_entries
    rename_table :versioned_revisions, :revisions
    rename_table :versioned_tags_revisions, :tags_revisions
    rename_table :versioned_statuses, :statuses
    rename_table :versioned_removals, :removals
    rename_table :versioned_internal_notes, :internal_notes

    rename_table :versioned_images, :images
    rename_table :versioned_image_revisions, :image_revisions
    rename_table :versioned_image_metadata_revisions, :image_metadata_revisions
    rename_table :versioned_image_file_revisions, :image_file_revisions
    rename_table :versioned_image_assets, :image_assets
  end
end
