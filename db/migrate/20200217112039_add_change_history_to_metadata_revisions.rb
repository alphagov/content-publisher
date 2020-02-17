class AddChangeHistoryToMetadataRevisions < ActiveRecord::Migration[6.0]
  def change
    add_column :metadata_revisions, :change_history, :json, default: [], null: false
  end
end
