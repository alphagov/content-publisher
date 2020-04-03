class AllowOfficialDocumentTypeToBeNull < ActiveRecord::Migration[6.0]
  def up
    change_column :file_attachment_metadata_revisions, :official_document_type, :string, null: true, default: nil
  end

  def down
    change_column :file_attachment_metadata_revisions, :official_document_type, :string, null: false, default: "unofficial"
  end
end
