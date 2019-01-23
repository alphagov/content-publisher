# frozen_string_literal: true

class RestrictDeleteForAllForeignKeys < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key "versioned_content_revisions", column: "created_by_id"
    remove_foreign_key "versioned_documents", column: "created_by_id"
    remove_foreign_key "versioned_edition_revisions", column: "edition_id"
    remove_foreign_key "versioned_edition_revisions", column: "revision_id"
    remove_foreign_key "versioned_editions", column: "created_by_id"
    remove_foreign_key "versioned_editions", column: "last_edited_by_id"
    remove_foreign_key "versioned_image_assets", column: "superseded_by_id"
    remove_foreign_key "versioned_image_assets", column: "file_revision_id"
    remove_foreign_key "versioned_image_file_revisions", column: "created_by_id"
    remove_foreign_key "versioned_image_metadata_revisions", column: "created_by_id"
    remove_foreign_key "versioned_image_revisions", column: "created_by_id"
    remove_foreign_key "versioned_images", column: "created_by_id"
    remove_foreign_key "versioned_internal_notes", column: "created_by_id"
    remove_foreign_key "versioned_internal_notes", column: "edition_id"
    remove_foreign_key "versioned_revision_image_revisions", column: "revision_id"
    remove_foreign_key "versioned_revision_statuses", column: "revision_id"
    remove_foreign_key "versioned_revision_statuses", column: "status_id"
    remove_foreign_key "versioned_revisions", column: "created_by_id"
    remove_foreign_key "versioned_revisions", column: "preceded_by_id"
    remove_foreign_key "versioned_statuses", column: "created_by_id"
    remove_foreign_key "versioned_statuses", column: "edition_id"
    remove_foreign_key "versioned_tags_revisions", column: "created_by_id"
    remove_foreign_key "versioned_timeline_entries", column: "created_by_id"
    remove_foreign_key "versioned_timeline_entries", column: "document_id"
    remove_foreign_key "versioned_timeline_entries", column: "edition_id"
    remove_foreign_key "versioned_timeline_entries", column: "revision_id"
    remove_foreign_key "versioned_timeline_entries", column: "status_id"
    remove_foreign_key "versioned_update_revisions", column: "created_by_id"

    add_foreign_key "versioned_content_revisions", "users", column: "created_by_id", on_delete: :restrict
    add_foreign_key "versioned_documents", "users", column: "created_by_id", on_delete: :restrict
    add_foreign_key "versioned_edition_revisions", "versioned_editions", column: "edition_id", on_delete: :restrict
    add_foreign_key "versioned_edition_revisions", "versioned_revisions", column: "revision_id", on_delete: :restrict
    add_foreign_key "versioned_editions", "users", column: "created_by_id", on_delete: :restrict
    add_foreign_key "versioned_editions", "users", column: "last_edited_by_id", on_delete: :restrict
    add_foreign_key "versioned_image_assets", "versioned_image_assets", column: "superseded_by_id", on_delete: :restrict
    add_foreign_key "versioned_image_assets", "versioned_image_file_revisions", column: "file_revision_id", on_delete: :restrict
    add_foreign_key "versioned_image_file_revisions", "users", column: "created_by_id", on_delete: :restrict
    add_foreign_key "versioned_image_metadata_revisions", "users", column: "created_by_id", on_delete: :restrict
    add_foreign_key "versioned_image_revisions", "users", column: "created_by_id", on_delete: :restrict
    add_foreign_key "versioned_images", "users", column: "created_by_id", on_delete: :restrict
    add_foreign_key "versioned_internal_notes", "users", column: "created_by_id", on_delete: :restrict
    add_foreign_key "versioned_internal_notes", "versioned_editions", column: "edition_id", on_delete: :restrict
    add_foreign_key "versioned_revision_image_revisions", "versioned_revisions", column: "revision_id", on_delete: :restrict
    add_foreign_key "versioned_revision_statuses", "versioned_revisions", column: "revision_id", on_delete: :restrict
    add_foreign_key "versioned_revision_statuses", "versioned_statuses", column: "status_id", on_delete: :restrict
    add_foreign_key "versioned_revisions", "users", column: "created_by_id", on_delete: :restrict
    add_foreign_key "versioned_revisions", "versioned_revisions", column: "preceded_by_id", on_delete: :restrict
    add_foreign_key "versioned_statuses", "users", column: "created_by_id", on_delete: :restrict
    add_foreign_key "versioned_statuses", "versioned_editions", column: "edition_id", on_delete: :restrict
    add_foreign_key "versioned_tags_revisions", "users", column: "created_by_id", on_delete: :restrict
    add_foreign_key "versioned_timeline_entries", "users", column: "created_by_id", on_delete: :restrict
    add_foreign_key "versioned_timeline_entries", "versioned_documents", column: "document_id", on_delete: :restrict
    add_foreign_key "versioned_timeline_entries", "versioned_editions", column: "edition_id", on_delete: :restrict
    add_foreign_key "versioned_timeline_entries", "versioned_revisions", column: "revision_id", on_delete: :restrict
    add_foreign_key "versioned_timeline_entries", "versioned_statuses", column: "status_id", on_delete: :restrict
    add_foreign_key "versioned_update_revisions", "users", column: "created_by_id", on_delete: :restrict
  end

  def down
    remove_foreign_key "versioned_content_revisions", column: "created_by_id"
    remove_foreign_key "versioned_documents", column: "created_by_id"
    remove_foreign_key "versioned_edition_revisions", column: "edition_id"
    remove_foreign_key "versioned_edition_revisions", column: "revision_id"
    remove_foreign_key "versioned_editions", column: "created_by_id"
    remove_foreign_key "versioned_editions", column: "last_edited_by_id"
    remove_foreign_key "versioned_image_assets", column: "superseded_by_id"
    remove_foreign_key "versioned_image_assets", column: "file_revision_id"
    remove_foreign_key "versioned_image_file_revisions", column: "created_by_id"
    remove_foreign_key "versioned_image_metadata_revisions", column: "created_by_id"
    remove_foreign_key "versioned_image_revisions", column: "created_by_id"
    remove_foreign_key "versioned_images", column: "created_by_id"
    remove_foreign_key "versioned_internal_notes", column: "created_by_id"
    remove_foreign_key "versioned_internal_notes", column: "edition_id"
    remove_foreign_key "versioned_revision_image_revisions", column: "revision_id"
    remove_foreign_key "versioned_revision_statuses", column: "revision_id"
    remove_foreign_key "versioned_revision_statuses", column: "status_id"
    remove_foreign_key "versioned_revisions", column: "created_by_id"
    remove_foreign_key "versioned_revisions", column: "preceded_by_id"
    remove_foreign_key "versioned_statuses", column: "created_by_id"
    remove_foreign_key "versioned_statuses", column: "edition_id"
    remove_foreign_key "versioned_tags_revisions", column: "created_by_id"
    remove_foreign_key "versioned_timeline_entries", column: "created_by_id"
    remove_foreign_key "versioned_timeline_entries", column: "document_id"
    remove_foreign_key "versioned_timeline_entries", column: "edition_id"
    remove_foreign_key "versioned_timeline_entries", column: "revision_id"
    remove_foreign_key "versioned_timeline_entries", column: "status_id"
    remove_foreign_key "versioned_update_revisions", column: "created_by_id"

    add_foreign_key "versioned_content_revisions", "users", column: "created_by_id", on_delete: :nullify
    add_foreign_key "versioned_documents", "users", column: "created_by_id", on_delete: :nullify
    add_foreign_key "versioned_edition_revisions", "versioned_editions", column: "edition_id", on_delete: :cascade
    add_foreign_key "versioned_edition_revisions", "versioned_revisions", column: "revision_id", on_delete: :cascade
    add_foreign_key "versioned_editions", "users", column: "created_by_id", on_delete: :nullify
    add_foreign_key "versioned_editions", "users", column: "last_edited_by_id", on_delete: :nullify
    add_foreign_key "versioned_image_assets", "versioned_image_assets", column: "superseded_by_id", on_delete: :nullify
    add_foreign_key "versioned_image_assets", "versioned_image_file_revisions", column: "file_revision_id", on_delete: :cascade
    add_foreign_key "versioned_image_file_revisions", "users", column: "created_by_id", on_delete: :nullify
    add_foreign_key "versioned_image_metadata_revisions", "users", column: "created_by_id", on_delete: :nullify
    add_foreign_key "versioned_image_revisions", "users", column: "created_by_id", on_delete: :nullify
    add_foreign_key "versioned_images", "users", column: "created_by_id", on_delete: :nullify
    add_foreign_key "versioned_internal_notes", "users", column: "created_by_id", on_delete: :nullify
    add_foreign_key "versioned_internal_notes", "versioned_editions", column: "edition_id", on_delete: :cascade
    add_foreign_key "versioned_revision_image_revisions", "versioned_revisions", column: "revision_id", on_delete: :cascade
    add_foreign_key "versioned_revision_statuses", "versioned_revisions", column: "revision_id", on_delete: :cascade
    add_foreign_key "versioned_revision_statuses", "versioned_statuses", column: "status_id", on_delete: :cascade
    add_foreign_key "versioned_revisions", "users", column: "created_by_id", on_delete: :nullify
    add_foreign_key "versioned_revisions", "versioned_revisions", column: "preceded_by_id", on_delete: :nullify
    add_foreign_key "versioned_statuses", "users", column: "created_by_id", on_delete: :nullify
    add_foreign_key "versioned_statuses", "versioned_editions", column: "edition_id", on_delete: :cascade
    add_foreign_key "versioned_tags_revisions", "users", column: "created_by_id", on_delete: :nullify
    add_foreign_key "versioned_timeline_entries", "users", column: "created_by_id", on_delete: :nullify
    add_foreign_key "versioned_timeline_entries", "versioned_documents", column: "document_id", on_delete: :cascade
    add_foreign_key "versioned_timeline_entries", "versioned_editions", column: "edition_id", on_delete: :cascade
    add_foreign_key "versioned_timeline_entries", "versioned_revisions", column: "revision_id", on_delete: :nullify
    add_foreign_key "versioned_timeline_entries", "versioned_statuses", column: "status_id", on_delete: :nullify
    add_foreign_key "versioned_update_revisions", "users", column: "created_by_id", on_delete: :nullify
  end
end
