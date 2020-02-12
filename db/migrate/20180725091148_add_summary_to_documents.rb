class AddSummaryToDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :summary, :text
  end
end
