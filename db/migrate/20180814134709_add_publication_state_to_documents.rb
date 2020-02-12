class AddPublicationStateToDocuments < ActiveRecord::Migration[5.2]
  def up
    execute "TRUNCATE documents"
    add_column :documents, :publication_state, :string, null: false # rubocop:disable Rails/NotNullColumn
  end

  def down; end
end
