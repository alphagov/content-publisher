class AddRemovedAtToRemovals < ActiveRecord::Migration[6.0]
  def change
    add_column :removals, :removed_at, :datetime
  end
end
