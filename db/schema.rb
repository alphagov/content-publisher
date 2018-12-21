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

ActiveRecord::Schema.define(version: 2018_12_21_114444) do

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
    t.bigint "document_id"
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

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.text "object_changes"
    t.datetime "created_at"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
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
  add_foreign_key "retirements", "documents"
  add_foreign_key "retirements", "timeline_entries", column: "timeline_entries_id", on_delete: :cascade
  add_foreign_key "timeline_entries", "documents", on_delete: :cascade
  add_foreign_key "timeline_entries", "users", on_delete: :nullify
end
