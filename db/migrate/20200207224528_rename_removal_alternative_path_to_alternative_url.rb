class RenameRemovalAlternativePathToAlternativeUrl < ActiveRecord::Migration[6.0]
  def change
    rename_column :removals, :alternative_path, :alternative_url
  end
end
