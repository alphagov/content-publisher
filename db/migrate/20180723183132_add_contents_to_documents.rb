class AddContentsToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :contents, :json, default: "{}"
  end
end
