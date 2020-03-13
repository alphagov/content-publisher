class AddFileAttachmentMetadataForPublications < ActiveRecord::Migration[6.0]
  def change
    change_table :file_attachment_metadata_revisions, bulk: true do |t|
      t.string :isbn
      t.string :unique_reference
      t.string :paper_number
      t.string :parliamentary_session
      t.string :official_document, default: "unofficial", null: false
    end
  end
end
