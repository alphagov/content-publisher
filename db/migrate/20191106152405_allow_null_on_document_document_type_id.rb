class AllowNullOnDocumentDocumentTypeId < ActiveRecord::Migration[5.2]
  def change
    change_column_null(Document, :document_type_id, true)
  end
end
