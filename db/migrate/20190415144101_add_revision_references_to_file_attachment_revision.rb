# frozen_string_literal: true

class AddRevisionReferencesToFileAttachmentRevision < ActiveRecord::Migration[5.2]
  def change
    change_table :file_attachment_revisions, bulk: true do |t|
      t.references :file_revision,
                   foreign_key: { to_table: :file_attachment_file_revisions,
                                  on_delete: :restrict },
                   index: true,
                   null: false
      t.references :metadata_revision,
                   foreign_key: { to_table: :file_attachment_metadata_revisions,
                                  on_delete: :restrict },
                   index: true,
                   null: false
    end
  end
end
