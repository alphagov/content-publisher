class AddImportedToRevision < ActiveRecord::Migration[5.2]
  def change
    add_column :revisions, :imported, :boolean, default: false
  end
end
