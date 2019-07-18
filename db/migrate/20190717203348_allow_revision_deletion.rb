# frozen_string_literal: true

class AllowRevisionDeletion < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :revisions_image_revisions, :revisions
    add_foreign_key :revisions_image_revisions,
                    :revisions,
                    on_delete: :cascade

    remove_foreign_key :image_assets, :image_blob_revisions
    add_foreign_key :image_assets,
                    :image_blob_revisions,
                    column: :blob_revision_id,
                    on_delete: :cascade

    remove_foreign_key :image_assets, :image_assets
    add_foreign_key :image_assets,
                    :image_assets,
                    column: :superseded_by_id,
                    on_delete: :nullify

    remove_foreign_key :revisions_file_attachment_revisions, :revisions
    add_foreign_key :revisions_file_attachment_revisions,
                    :revisions,
                    on_delete: :cascade

    remove_foreign_key :file_attachment_assets, :file_attachment_blob_revisions
    add_foreign_key :file_attachment_assets,
                    :file_attachment_blob_revisions,
                    column: :blob_revision_id,
                    on_delete: :cascade

    remove_foreign_key :file_attachment_assets, :file_attachment_assets
    add_foreign_key :file_attachment_assets,
                    :file_attachment_assets,
                    column: :superseded_by_id,
                    on_delete: :nullify
  end

  def down
    remove_foreign_key :revisions_image_revisions, :revisions
    add_foreign_key :revisions_image_revisions,
                    :revisions,
                    on_delete: :restrict

    remove_foreign_key :image_assets, :image_blob_revisions
    add_foreign_key :image_assets,
                    :image_blob_revisions,
                    column: :blob_revision_id,
                    on_delete: :restrict

    remove_foreign_key :image_assets, :image_assets
    add_foreign_key :image_assets,
                    :image_assets,
                    column: :superseded_by_id,
                    on_delete: :restrict

    remove_foreign_key :revisions_file_attachment_revisions, :revisions
    add_foreign_key :revisions_file_attachment_revisions,
                    :revisions,
                    on_delete: :restrict

    remove_foreign_key :file_attachment_assets, :file_attachment_blob_revisions
    add_foreign_key :file_attachment_assets,
                    :file_attachment_blob_revisions,
                    column: :blob_revision_id,
                    on_delete: :restrict

    remove_foreign_key :file_attachment_assets, :file_attachment_assets
    add_foreign_key :file_attachment_assets,
                    :file_attachment_assets,
                    column: :superseded_by_id,
                    on_delete: :restrict
  end
end
