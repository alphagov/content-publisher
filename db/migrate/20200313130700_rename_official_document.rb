class RenameOfficialDocument < ActiveRecord::Migration[6.0]
  def change
    rename_column :file_attachment_metadata_revisions, :official_document, :official_document_type
  end
end
