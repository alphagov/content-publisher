# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_01_21_180333) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "documents", force: :cascade do |t|
    t.string "content_id", null: false
    t.string "locale", null: false
    t.string "document_type_id", null: false
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "contents", default: {}
    t.text "summary"
    t.string "base_path"
    t.json "tags", default: {}
    t.string "publication_state", null: false
    t.bigint "creator_id"
    t.string "review_state", null: false
    t.boolean "has_live_version_on_govuk", default: false, null: false
    t.text "change_note"
    t.string "update_type"
    t.bigint "lead_image_id"
    t.integer "current_edition_number", null: false
    t.bigint "last_editor_id"
    t.string "live_state"
    t.index ["base_path"], name: "index_documents_on_base_path", unique: true
    t.index ["content_id", "locale"], name: "index_documents_on_content_id_and_locale", unique: true
    t.index ["creator_id"], name: "index_documents_on_creator_id"
    t.index ["last_editor_id"], name: "index_documents_on_last_editor_id"
    t.index ["lead_image_id"], name: "index_documents_on_lead_image_id"
  end

  create_table "images", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.bigint "blob_id", null: false
    t.string "filename", null: false
    t.integer "width", null: false
    t.integer "height", null: false
    t.integer "crop_x", null: false
    t.integer "crop_y", null: false
    t.integer "crop_width", null: false
    t.integer "crop_height", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "caption"
    t.string "alt_text"
    t.string "credit"
    t.string "asset_manager_file_url"
    t.string "publication_state", null: false
    t.index ["blob_id"], name: "index_images_on_blob_id"
    t.index ["document_id"], name: "index_images_on_document_id"
  end

  create_table "internal_notes", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "document_id", null: false
    t.bigint "user_id"
    t.bigint "timeline_entries_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["document_id"], name: "index_internal_notes_on_document_id"
    t.index ["timeline_entries_id"], name: "index_internal_notes_on_timeline_entries_id"
    t.index ["user_id"], name: "index_internal_notes_on_user_id"
  end

  create_table "removals", force: :cascade do |t|
    t.string "explanatory_note"
    t.string "alternative_path"
    t.boolean "redirect", default: false
    t.bigint "timeline_entries_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["timeline_entries_id"], name: "index_removals_on_timeline_entries_id"
  end

  create_table "retirements", force: :cascade do |t|
    t.string "explanatory_note"
    t.bigint "timeline_entries_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["timeline_entries_id"], name: "index_retirements_on_timeline_entries_id"
  end

  create_table "timeline_entries", force: :cascade do |t|
    t.string "entry_type", null: false
    t.bigint "document_id", null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "edition_number", null: false
    t.index ["document_id"], name: "index_timeline_entries_on_document_id"
    t.index ["user_id"], name: "index_timeline_entries_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "uid"
    t.string "organisation_slug"
    t.string "organisation_content_id"
    t.string "app_name"
    t.text "permissions"
    t.boolean "remotely_signed_out", default: false
    t.boolean "disabled", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "versioned_content_revisions", force: :cascade do |t|
    t.string "title"
    t.string "base_path"
    t.text "summary"
    t.json "contents", default: {}, null: false
    t.datetime "created_at"
    t.bigint "created_by_id"
  end

  create_table "versioned_documents", force: :cascade do |t|
    t.uuid "content_id", null: false
    t.string "locale", null: false
    t.string "document_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by_id"
    t.datetime "first_published_at"
    t.index ["content_id", "locale"], name: "index_versioned_documents_on_content_id_and_locale", unique: true
    t.index ["created_by_id"], name: "index_versioned_documents_on_created_by_id"
  end

  create_table "versioned_edition_revisions", force: :cascade do |t|
    t.bigint "edition_id", null: false
    t.bigint "revision_id", null: false
    t.datetime "created_at", null: false
    t.index ["edition_id", "revision_id"], name: "index_versioned_edition_revisions_on_edition_id_and_revision_id", unique: true
    t.index ["edition_id"], name: "index_versioned_edition_revisions_on_edition_id"
    t.index ["revision_id"], name: "index_versioned_edition_revisions_on_revision_id"
  end

  create_table "versioned_editions", force: :cascade do |t|
    t.integer "number", null: false
    t.datetime "last_edited_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "document_id", null: false
    t.bigint "created_by_id"
    t.boolean "current", default: false, null: false
    t.boolean "live", default: false, null: false
    t.bigint "last_edited_by_id"
    t.bigint "status_id", null: false
    t.bigint "revision_id", null: false
    t.boolean "revision_synced", default: false, null: false
    t.index ["created_by_id"], name: "index_versioned_editions_on_created_by_id"
    t.index ["current"], name: "index_versioned_editions_on_current"
    t.index ["document_id", "current"], name: "index_versioned_editions_on_document_id_and_current", unique: true, where: "(current = true)"
    t.index ["document_id", "live"], name: "index_versioned_editions_on_document_id_and_live", unique: true, where: "(live = true)"
    t.index ["document_id", "number"], name: "index_versioned_editions_on_document_id_and_number", unique: true
    t.index ["document_id"], name: "index_versioned_editions_on_document_id"
    t.index ["last_edited_by_id"], name: "index_versioned_editions_on_last_edited_by_id"
    t.index ["live"], name: "index_versioned_editions_on_live"
    t.index ["revision_id"], name: "index_versioned_editions_on_revision_id"
    t.index ["status_id"], name: "index_versioned_editions_on_status_id"
  end

  create_table "versioned_image_assets", force: :cascade do |t|
    t.bigint "file_revision_id", null: false
    t.bigint "superseded_by_id"
    t.string "variant", null: false
    t.string "file_url"
    t.string "state", default: "absent", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["file_revision_id", "variant"], name: "index_versioned_image_asset_unique_variant", unique: true
    t.index ["file_revision_id"], name: "index_versioned_image_assets_on_file_revision_id"
    t.index ["file_url"], name: "index_versioned_image_assets_on_file_url", unique: true
  end

  create_table "versioned_image_file_revisions", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.bigint "created_by_id"
    t.integer "width", null: false
    t.integer "height", null: false
    t.integer "crop_x", null: false
    t.integer "crop_y", null: false
    t.integer "crop_width", null: false
    t.integer "crop_height", null: false
    t.string "filename", null: false
    t.datetime "created_at"
    t.index ["blob_id"], name: "index_versioned_image_file_revisions_on_blob_id"
  end

  create_table "versioned_image_metadata_revisions", force: :cascade do |t|
    t.string "caption"
    t.string "alt_text"
    t.string "credit"
    t.datetime "created_at"
    t.bigint "created_by_id"
  end

  create_table "versioned_image_revisions", force: :cascade do |t|
    t.bigint "image_id", null: false
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.bigint "file_revision_id", null: false
    t.bigint "metadata_revision_id", null: false
    t.index ["file_revision_id"], name: "index_versioned_image_revisions_on_file_revision_id"
    t.index ["image_id"], name: "index_versioned_image_revisions_on_image_id"
    t.index ["metadata_revision_id"], name: "index_versioned_image_revisions_on_metadata_revision_id"
  end

  create_table "versioned_images", force: :cascade do |t|
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
  end

  create_table "versioned_internal_notes", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "edition_id", null: false
    t.bigint "created_by_id"
    t.datetime "created_at"
    t.index ["created_by_id"], name: "index_versioned_internal_notes_on_created_by_id"
    t.index ["edition_id"], name: "index_versioned_internal_notes_on_edition_id"
  end

  create_table "versioned_removals", force: :cascade do |t|
    t.string "explanatory_note"
    t.string "alternative_path"
    t.boolean "redirect", default: false
    t.datetime "created_at", null: false
  end

  create_table "versioned_retirements", force: :cascade do |t|
    t.string "explanatory_note"
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
  end

  create_table "versioned_revision_image_revisions", force: :cascade do |t|
    t.bigint "image_revision_id", null: false
    t.bigint "revision_id", null: false
    t.datetime "created_at", null: false
    t.index ["image_revision_id"], name: "index_versioned_revision_image_revisions_on_image_revision_id"
    t.index ["revision_id"], name: "index_versioned_revision_image_revisions_on_revision_id"
  end

  create_table "versioned_revision_statuses", force: :cascade do |t|
    t.bigint "revision_id", null: false
    t.bigint "status_id", null: false
    t.datetime "created_at", null: false
    t.index ["revision_id", "status_id"], name: "index_versioned_revision_statuses_on_revision_id_and_status_id", unique: true
    t.index ["revision_id"], name: "index_versioned_revision_statuses_on_revision_id"
    t.index ["status_id"], name: "index_versioned_revision_statuses_on_status_id"
  end

  create_table "versioned_revisions", force: :cascade do |t|
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.bigint "document_id", null: false
    t.bigint "lead_image_revision_id"
    t.bigint "content_revision_id", null: false
    t.bigint "update_revision_id", null: false
    t.bigint "tags_revision_id", null: false
    t.bigint "preceded_by_id"
    t.integer "number", null: false
    t.index ["content_revision_id"], name: "index_versioned_revisions_on_content_revision_id"
    t.index ["created_by_id"], name: "index_versioned_revisions_on_created_by_id"
    t.index ["document_id"], name: "index_versioned_revisions_on_document_id"
    t.index ["lead_image_revision_id"], name: "index_versioned_revisions_on_lead_image_revision_id"
    t.index ["number", "document_id"], name: "index_versioned_revisions_on_number_and_document_id", unique: true
    t.index ["preceded_by_id"], name: "index_versioned_revisions_on_preceded_by_id"
    t.index ["tags_revision_id"], name: "index_versioned_revisions_on_tags_revision_id"
    t.index ["update_revision_id"], name: "index_versioned_revisions_on_update_revision_id"
  end

  create_table "versioned_statuses", force: :cascade do |t|
    t.string "state", null: false
    t.bigint "revision_at_creation_id", null: false
    t.bigint "edition_id"
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "details_type"
    t.bigint "details_id"
    t.index ["created_by_id"], name: "index_versioned_statuses_on_created_by_id"
    t.index ["details_type", "details_id"], name: "index_versioned_statuses_on_details_type_and_details_id"
    t.index ["edition_id"], name: "index_versioned_statuses_on_edition_id"
    t.index ["revision_at_creation_id"], name: "index_versioned_statuses_on_revision_at_creation_id"
    t.index ["state"], name: "index_versioned_statuses_on_state"
  end

  create_table "versioned_tags_revisions", force: :cascade do |t|
    t.json "tags", default: {}, null: false
    t.datetime "created_at"
    t.bigint "created_by_id"
  end

  create_table "versioned_timeline_entries", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.bigint "edition_id"
    t.bigint "revision_id"
    t.bigint "status_id"
    t.bigint "created_by_id"
    t.string "details_type"
    t.bigint "details_id"
    t.datetime "created_at", null: false
    t.string "entry_type", null: false
    t.index ["created_by_id"], name: "index_versioned_timeline_entries_on_created_by_id"
    t.index ["details_type", "details_id"], name: "index_versioned_timeline_entries_on_details_type_and_details_id"
    t.index ["document_id"], name: "index_versioned_timeline_entries_on_document_id"
    t.index ["edition_id"], name: "index_versioned_timeline_entries_on_edition_id"
  end

  create_table "versioned_update_revisions", force: :cascade do |t|
    t.string "update_type", null: false
    t.text "change_note"
    t.datetime "created_at"
    t.bigint "created_by_id"
  end

  add_foreign_key "documents", "images", column: "lead_image_id", on_delete: :nullify
  add_foreign_key "documents", "users", column: "creator_id"
  add_foreign_key "documents", "users", column: "last_editor_id"
  add_foreign_key "images", "active_storage_blobs", column: "blob_id", on_delete: :cascade
  add_foreign_key "images", "documents", on_delete: :cascade
  add_foreign_key "internal_notes", "documents", on_delete: :cascade
  add_foreign_key "internal_notes", "timeline_entries", column: "timeline_entries_id"
  add_foreign_key "internal_notes", "users", on_delete: :nullify
  add_foreign_key "removals", "timeline_entries", column: "timeline_entries_id", on_delete: :cascade
  add_foreign_key "retirements", "timeline_entries", column: "timeline_entries_id", on_delete: :cascade
  add_foreign_key "timeline_entries", "documents", on_delete: :cascade
  add_foreign_key "timeline_entries", "users", on_delete: :nullify
  add_foreign_key "versioned_content_revisions", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "versioned_documents", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "versioned_edition_revisions", "versioned_editions", column: "edition_id", on_delete: :cascade
  add_foreign_key "versioned_edition_revisions", "versioned_revisions", column: "revision_id", on_delete: :cascade
  add_foreign_key "versioned_editions", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "versioned_editions", "users", column: "last_edited_by_id", on_delete: :nullify
  add_foreign_key "versioned_editions", "versioned_documents", column: "document_id", on_delete: :restrict
  add_foreign_key "versioned_editions", "versioned_revisions", column: "revision_id", on_delete: :restrict
  add_foreign_key "versioned_editions", "versioned_statuses", column: "status_id", on_delete: :restrict
  add_foreign_key "versioned_image_assets", "versioned_image_assets", column: "superseded_by_id", on_delete: :nullify
  add_foreign_key "versioned_image_assets", "versioned_image_file_revisions", column: "file_revision_id", on_delete: :cascade
  add_foreign_key "versioned_image_file_revisions", "active_storage_blobs", column: "blob_id", on_delete: :restrict
  add_foreign_key "versioned_image_file_revisions", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "versioned_image_metadata_revisions", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "versioned_image_revisions", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "versioned_image_revisions", "versioned_image_file_revisions", column: "file_revision_id", on_delete: :restrict
  add_foreign_key "versioned_image_revisions", "versioned_image_metadata_revisions", column: "metadata_revision_id", on_delete: :restrict
  add_foreign_key "versioned_image_revisions", "versioned_images", column: "image_id", on_delete: :restrict
  add_foreign_key "versioned_images", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "versioned_internal_notes", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "versioned_internal_notes", "versioned_editions", column: "edition_id", on_delete: :cascade
  add_foreign_key "versioned_retirements", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "versioned_revision_image_revisions", "versioned_image_revisions", column: "image_revision_id", on_delete: :restrict
  add_foreign_key "versioned_revision_image_revisions", "versioned_revisions", column: "revision_id", on_delete: :cascade
  add_foreign_key "versioned_revision_statuses", "versioned_revisions", column: "revision_id", on_delete: :cascade
  add_foreign_key "versioned_revision_statuses", "versioned_statuses", column: "status_id", on_delete: :cascade
  add_foreign_key "versioned_revisions", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "versioned_revisions", "versioned_content_revisions", column: "content_revision_id", on_delete: :restrict
  add_foreign_key "versioned_revisions", "versioned_documents", column: "document_id", on_delete: :restrict
  add_foreign_key "versioned_revisions", "versioned_image_revisions", column: "lead_image_revision_id", on_delete: :restrict
  add_foreign_key "versioned_revisions", "versioned_revisions", column: "preceded_by_id", on_delete: :nullify
  add_foreign_key "versioned_revisions", "versioned_tags_revisions", column: "tags_revision_id", on_delete: :restrict
  add_foreign_key "versioned_revisions", "versioned_update_revisions", column: "update_revision_id", on_delete: :restrict
  add_foreign_key "versioned_statuses", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "versioned_statuses", "versioned_editions", column: "edition_id", on_delete: :cascade
  add_foreign_key "versioned_statuses", "versioned_revisions", column: "revision_at_creation_id", on_delete: :restrict
  add_foreign_key "versioned_tags_revisions", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "versioned_timeline_entries", "users", column: "created_by_id", on_delete: :nullify
  add_foreign_key "versioned_timeline_entries", "versioned_documents", column: "document_id", on_delete: :cascade
  add_foreign_key "versioned_timeline_entries", "versioned_editions", column: "edition_id", on_delete: :cascade
  add_foreign_key "versioned_timeline_entries", "versioned_revisions", column: "revision_id", on_delete: :nullify
  add_foreign_key "versioned_timeline_entries", "versioned_statuses", column: "status_id", on_delete: :nullify
  add_foreign_key "versioned_update_revisions", "users", column: "created_by_id", on_delete: :nullify
end
