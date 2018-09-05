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

ActiveRecord::Schema.define(version: 2018_09_07_121447) do

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
    t.string "document_type"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.json "contents", default: {}
    t.string "base_path"
    t.text "summary"
    t.json "tags", default: {}
    t.string "publication_state", null: false
    t.bigint "creator_id"
    t.string "review_state", null: false
    t.text "change_note"
    t.string "update_type"
    t.boolean "has_live_version_on_govuk", default: false, null: false
    t.bigint "lead_image_id"
    t.index ["base_path"], name: "index_documents_on_base_path", unique: true
    t.index ["content_id", "locale"], name: "index_documents_on_content_id_and_locale", unique: true
    t.index ["creator_id"], name: "index_documents_on_creator_id"
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
    t.index ["blob_id"], name: "index_images_on_blob_id"
    t.index ["document_id"], name: "index_images_on_document_id"
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

  add_foreign_key "documents", "images", column: "lead_image_id"
  add_foreign_key "documents", "users", column: "creator_id"
  add_foreign_key "images", "active_storage_blobs", column: "blob_id", on_delete: :cascade
  add_foreign_key "images", "documents", on_delete: :cascade
end
