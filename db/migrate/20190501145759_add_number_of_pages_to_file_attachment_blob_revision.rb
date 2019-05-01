# frozen_string_literal: true

class AddNumberOfPagesToFileAttachmentBlobRevision < ActiveRecord::Migration[5.2]
  def change
    add_column :file_attachment_blob_revisions, :number_of_pages, :integer
  end
end
