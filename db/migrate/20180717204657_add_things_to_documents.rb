class AddThingsToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :publication_state, :string
    add_column :documents, :description, :text
    add_column :documents, :current_edition_number, :integer
  end
end
