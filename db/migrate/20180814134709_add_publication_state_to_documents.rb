class AddPublicationStateToDocuments < ActiveRecord::Migration[5.2]
  def change
    execute "TRUNCATE documents"
    add_column :documents, :publication_state, :string, null: false
  end
end
