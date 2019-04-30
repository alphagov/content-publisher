# frozen_string_literal: true

class RemoveRedundantFileAttachmentSize < ActiveRecord::Migration[5.2]
  def change
    remove_column :file_attachment_blob_revisions, :size # rubocop:disable Rails/ReversibleMigration
  end
end
