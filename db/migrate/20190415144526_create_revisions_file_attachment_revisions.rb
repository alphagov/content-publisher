# frozen_string_literal: true

class CreateRevisionsFileAttachmentRevisions < ActiveRecord::Migration[5.2]
  def change
    create_table :revisions_file_attachment_revisions do |t|
      t.references :file_attachment_revision,
                   foreign_key: { to_table: :file_attachment_revisions,
                                  on_delete: :restrict },
                   index: { name: :index_revisions_file_attachment_on_file_attachment_revision_id },
                   null: false
      t.references :revision,
                   foreign_key: { to_table: :revisions,
                                  on_delete: :restrict },
                   index: true,
                   null: false
      t.datetime :created_at, null: false
    end
  end
end
