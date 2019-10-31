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

ActiveRecord::Schema.define(version: 2019_10_30_093601) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "access_limits", force: :cascade do |t|
    t.datetime "created_at"
    t.bigint "created_by_id"
    t.bigint "edition_id", null: false
    t.bigint "revision_at_creation_id", null: false
    t.string "limit_type", null: false
  end

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

  create_table "content_revisions", force: :cascade do |t|
    t.string "title"
    t.string "base_path"
    t.text "summary"
    t.json "contents", default: {}, null: false
    t.datetime "created_at"
    t.bigint "created_by_id"
  end

  create_table "documents", force: :cascade do |t|
    t.uuid "content_id", null: false
    t.string "locale", null: false
    t.string "document_type_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "created_by_id"
    t.datetime "first_published_at"
    t.string "imported_from"
    t.index ["content_id", "locale"], name: "index_documents_on_content_id_and_locale", unique: true
    t.index ["created_by_id"], name: "index_documents_on_created_by_id"
  end

  create_table "editions", force: :cascade do |t|
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
    t.bigint "access_limit_id"
    t.index ["access_limit_id"], name: "index_editions_on_access_limit_id"
    t.index ["created_by_id"], name: "index_editions_on_created_by_id"
    t.index ["document_id", "current"], name: "index_editions_on_document_id_and_current", unique: true, where: "(current = true)"
    t.index ["document_id", "live"], name: "index_editions_on_document_id_and_live", unique: true, where: "(live = true)"
    t.index ["document_id", "number"], name: "index_editions_on_document_id_and_number", unique: true
    t.index ["document_id"], name: "index_editions_on_document_id"
    t.index ["last_edited_by_id"], name: "index_editions_on_last_edited_by_id"
    t.index ["revision_id"], name: "index_editions_on_revision_id"
    t.index ["status_id"], name: "index_editions_on_status_id"
  end

  create_table "editions_revisions", force: :cascade do |t|
    t.bigint "edition_id", null: false
    t.bigint "revision_id", null: false
    t.datetime "created_at", null: false
    t.index ["edition_id", "revision_id"], name: "index_editions_revisions_on_edition_id_and_revision_id", unique: true
    t.index ["edition_id"], name: "index_editions_revisions_on_edition_id"
    t.index ["revision_id"], name: "index_editions_revisions_on_revision_id"
  end

  create_table "file_attachment_assets", force: :cascade do |t|
    t.bigint "blob_revision_id", null: false
    t.string "file_url"
    t.string "state", default: "absent", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "superseded_by_id"
    t.index ["blob_revision_id"], name: "index_file_attachment_assets_on_blob_revision_id", unique: true
    t.index ["file_url"], name: "index_file_attachment_assets_on_file_url", unique: true
  end

  create_table "file_attachment_blob_revisions", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.bigint "created_by_id"
    t.string "filename", null: false
    t.datetime "created_at", null: false
    t.integer "number_of_pages"
    t.index ["blob_id"], name: "index_file_attachment_blob_revisions_on_blob_id"
  end

  create_table "file_attachment_metadata_revisions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.bigint "created_by_id"
  end

  create_table "file_attachment_revisions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
    t.bigint "file_attachment_id", null: false
    t.bigint "blob_revision_id", null: false
    t.bigint "metadata_revision_id", null: false
    t.index ["blob_revision_id"], name: "index_file_attachment_revisions_on_blob_revision_id"
    t.index ["file_attachment_id"], name: "index_file_attachment_revisions_on_file_attachment_id"
    t.index ["metadata_revision_id"], name: "index_file_attachment_revisions_on_metadata_revision_id"
  end

  create_table "file_attachments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "created_by_id"
  end

  create_table "image_assets", force: :cascade do |t|
    t.bigint "blob_revision_id", null: false
    t.bigint "superseded_by_id"
    t.string "variant", null: false
    t.string "file_url"
    t.string "state", default: "absent", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blob_revision_id", "variant"], name: "index_image_asset_unique_variant", unique: true
    t.index ["blob_revision_id"], name: "index_image_assets_on_blob_revision_id"
    t.index ["file_url"], name: "index_image_assets_on_file_url", unique: true
  end

  create_table "image_blob_revisions", force: :cascade do |t|
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
    t.index ["blob_id"], name: "index_image_blob_revisions_on_blob_id"
  end

  create_table "image_metadata_revisions", force: :cascade do |t|
    t.string "caption"
    t.string "alt_text"
    t.string "credit"
    t.datetime "created_at"
    t.bigint "created_by_id"
  end

  create_table "image_revisions", force: :cascade do |t|
    t.bigint "image_id", null: false
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.bigint "blob_revision_id", null: false
    t.bigint "metadata_revision_id", null: false
    t.index ["blob_revision_id"], name: "index_image_revisions_on_blob_revision_id"
    t.index ["image_id"], name: "index_image_revisions_on_image_id"
    t.index ["metadata_revision_id"], name: "index_image_revisions_on_metadata_revision_id"
  end

  create_table "images", force: :cascade do |t|
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
  end

  create_table "internal_notes", force: :cascade do |t|
    t.text "body", null: false
    t.bigint "edition_id", null: false
    t.bigint "created_by_id"
    t.datetime "created_at"
    t.index ["created_by_id"], name: "index_internal_notes_on_created_by_id"
    t.index ["edition_id"], name: "index_internal_notes_on_edition_id"
  end

  create_table "metadata_revisions", force: :cascade do |t|
    t.string "update_type", null: false
    t.text "change_note"
    t.datetime "created_at"
    t.bigint "created_by_id"
    t.datetime "proposed_publish_time"
    t.datetime "backdated_to"
  end

  create_table "removals", force: :cascade do |t|
    t.string "explanatory_note"
    t.string "alternative_path"
    t.boolean "redirect", default: false
    t.datetime "created_at", null: false
  end

  create_table "revisions", force: :cascade do |t|
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.bigint "document_id", null: false
    t.bigint "lead_image_revision_id"
    t.bigint "content_revision_id", null: false
    t.bigint "metadata_revision_id", null: false
    t.bigint "tags_revision_id", null: false
    t.bigint "preceded_by_id"
    t.integer "number", null: false
    t.boolean "imported", default: false
    t.index ["content_revision_id"], name: "index_revisions_on_content_revision_id"
    t.index ["created_by_id"], name: "index_revisions_on_created_by_id"
    t.index ["document_id"], name: "index_revisions_on_document_id"
    t.index ["lead_image_revision_id"], name: "index_revisions_on_lead_image_revision_id"
    t.index ["metadata_revision_id"], name: "index_revisions_on_metadata_revision_id"
    t.index ["number", "document_id"], name: "index_revisions_on_number_and_document_id", unique: true
    t.index ["preceded_by_id"], name: "index_revisions_on_preceded_by_id"
    t.index ["tags_revision_id"], name: "index_revisions_on_tags_revision_id"
  end

  create_table "revisions_file_attachment_revisions", force: :cascade do |t|
    t.bigint "file_attachment_revision_id", null: false
    t.bigint "revision_id", null: false
    t.datetime "created_at", null: false
    t.index ["file_attachment_revision_id"], name: "index_revisions_file_attachment_on_file_attachment_revision_id"
    t.index ["revision_id"], name: "index_revisions_file_attachment_revisions_on_revision_id"
  end

  create_table "revisions_image_revisions", force: :cascade do |t|
    t.bigint "image_revision_id", null: false
    t.bigint "revision_id", null: false
    t.datetime "created_at", null: false
    t.index ["image_revision_id"], name: "index_revisions_image_revisions_on_image_revision_id"
    t.index ["revision_id"], name: "index_revisions_image_revisions_on_revision_id"
  end

  create_table "revisions_statuses", force: :cascade do |t|
    t.bigint "revision_id", null: false
    t.bigint "status_id", null: false
    t.datetime "created_at", null: false
    t.index ["revision_id", "status_id"], name: "index_revisions_statuses_on_revision_id_and_status_id", unique: true
    t.index ["revision_id"], name: "index_revisions_statuses_on_revision_id"
    t.index ["status_id"], name: "index_revisions_statuses_on_status_id"
  end

  create_table "schedulings", force: :cascade do |t|
    t.boolean "reviewed", default: false
    t.datetime "created_at", null: false
    t.bigint "pre_scheduled_status_id", null: false
    t.datetime "publish_time", null: false
  end

  create_table "statuses", force: :cascade do |t|
    t.string "state", null: false
    t.bigint "revision_at_creation_id", null: false
    t.bigint "edition_id"
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "details_type"
    t.bigint "details_id"
    t.index ["created_by_id"], name: "index_statuses_on_created_by_id"
    t.index ["details_type", "details_id"], name: "index_statuses_on_details_type_and_details_id"
    t.index ["edition_id"], name: "index_statuses_on_edition_id"
    t.index ["revision_at_creation_id"], name: "index_statuses_on_revision_at_creation_id"
    t.index ["state"], name: "index_statuses_on_state"
  end

  create_table "tags_revisions", force: :cascade do |t|
    t.json "tags", default: {}, null: false
    t.datetime "created_at"
    t.bigint "created_by_id"
  end

  create_table "timeline_entries", force: :cascade do |t|
    t.bigint "document_id", null: false
    t.bigint "edition_id"
    t.bigint "revision_id"
    t.bigint "status_id"
    t.bigint "created_by_id"
    t.string "details_type"
    t.bigint "details_id"
    t.datetime "created_at", null: false
    t.string "entry_type", null: false
    t.index ["created_by_id"], name: "index_timeline_entries_on_created_by_id"
    t.index ["details_type", "details_id"], name: "index_timeline_entries_on_details_type_and_details_id"
    t.index ["document_id"], name: "index_timeline_entries_on_document_id"
    t.index ["edition_id"], name: "index_timeline_entries_on_edition_id"
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

  create_table "whitehall_imports", force: :cascade do |t|
    t.bigint "whitehall_document_id", null: false
    t.json "payload", null: false
    t.uuid "content_id", null: false
    t.string "state", null: false
    t.text "error_log"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "withdrawals", force: :cascade do |t|
    t.string "public_explanation", null: false
    t.datetime "created_at", null: false
    t.bigint "published_status_id", null: false
    t.datetime "withdrawn_at", null: false
  end

  add_foreign_key "access_limits", "editions", on_delete: :cascade
  add_foreign_key "access_limits", "revisions", column: "revision_at_creation_id", on_delete: :restrict
  add_foreign_key "access_limits", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "content_revisions", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "documents", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "editions", "access_limits", on_delete: :restrict
  add_foreign_key "editions", "documents", on_delete: :restrict
  add_foreign_key "editions", "revisions", on_delete: :restrict
  add_foreign_key "editions", "statuses", on_delete: :restrict
  add_foreign_key "editions", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "editions", "users", column: "last_edited_by_id", on_delete: :restrict
  add_foreign_key "editions_revisions", "editions", on_delete: :cascade
  add_foreign_key "editions_revisions", "revisions", on_delete: :restrict
  add_foreign_key "file_attachment_assets", "file_attachment_assets", column: "superseded_by_id", on_delete: :nullify
  add_foreign_key "file_attachment_assets", "file_attachment_blob_revisions", column: "blob_revision_id", on_delete: :cascade
  add_foreign_key "file_attachment_blob_revisions", "active_storage_blobs", column: "blob_id", on_delete: :restrict
  add_foreign_key "file_attachment_blob_revisions", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "file_attachment_metadata_revisions", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "file_attachment_revisions", "file_attachment_blob_revisions", column: "blob_revision_id", on_delete: :restrict
  add_foreign_key "file_attachment_revisions", "file_attachment_metadata_revisions", column: "metadata_revision_id", on_delete: :restrict
  add_foreign_key "file_attachment_revisions", "file_attachments", on_delete: :restrict
  add_foreign_key "file_attachment_revisions", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "file_attachments", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "image_assets", "image_assets", column: "superseded_by_id", on_delete: :nullify
  add_foreign_key "image_assets", "image_blob_revisions", column: "blob_revision_id", on_delete: :cascade
  add_foreign_key "image_blob_revisions", "active_storage_blobs", column: "blob_id", on_delete: :restrict
  add_foreign_key "image_blob_revisions", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "image_metadata_revisions", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "image_revisions", "image_blob_revisions", column: "blob_revision_id", on_delete: :restrict
  add_foreign_key "image_revisions", "image_metadata_revisions", column: "metadata_revision_id", on_delete: :restrict
  add_foreign_key "image_revisions", "images", on_delete: :restrict
  add_foreign_key "image_revisions", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "images", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "internal_notes", "editions", on_delete: :cascade
  add_foreign_key "internal_notes", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "metadata_revisions", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "revisions", "content_revisions", on_delete: :restrict
  add_foreign_key "revisions", "documents", on_delete: :restrict
  add_foreign_key "revisions", "image_revisions", column: "lead_image_revision_id", on_delete: :restrict
  add_foreign_key "revisions", "metadata_revisions", on_delete: :restrict
  add_foreign_key "revisions", "revisions", column: "preceded_by_id", on_delete: :restrict
  add_foreign_key "revisions", "tags_revisions", on_delete: :restrict
  add_foreign_key "revisions", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "revisions_file_attachment_revisions", "file_attachment_revisions", on_delete: :restrict
  add_foreign_key "revisions_file_attachment_revisions", "revisions", on_delete: :cascade
  add_foreign_key "revisions_image_revisions", "image_revisions", on_delete: :restrict
  add_foreign_key "revisions_image_revisions", "revisions", on_delete: :cascade
  add_foreign_key "revisions_statuses", "revisions", on_delete: :restrict
  add_foreign_key "revisions_statuses", "statuses", on_delete: :cascade
  add_foreign_key "schedulings", "statuses", column: "pre_scheduled_status_id", on_delete: :restrict
  add_foreign_key "statuses", "editions", on_delete: :cascade
  add_foreign_key "statuses", "revisions", column: "revision_at_creation_id", on_delete: :restrict
  add_foreign_key "statuses", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "tags_revisions", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "timeline_entries", "documents", on_delete: :restrict
  add_foreign_key "timeline_entries", "editions", on_delete: :cascade
  add_foreign_key "timeline_entries", "revisions", on_delete: :restrict
  add_foreign_key "timeline_entries", "statuses", on_delete: :restrict
  add_foreign_key "timeline_entries", "users", column: "created_by_id", on_delete: :restrict
  add_foreign_key "withdrawals", "statuses", column: "published_status_id", on_delete: :restrict
end
