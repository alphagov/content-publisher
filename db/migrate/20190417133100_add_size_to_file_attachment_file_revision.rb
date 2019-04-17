# frozen_string_literal: true

class AddSizeToFileAttachmentFileRevision < ActiveRecord::Migration[5.2]
  def change
    add_column :file_attachment_file_revisions, :size, :bigint, null: false # rubocop:disable Rails/NotNullColumn
  end
end
