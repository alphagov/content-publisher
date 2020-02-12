class RenameAssociationsToTags < ActiveRecord::Migration[5.2]
  def change
    rename_column :documents, :associations, :tags
  end
end
