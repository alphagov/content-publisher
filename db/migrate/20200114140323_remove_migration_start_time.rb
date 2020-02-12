class RemoveMigrationStartTime < ActiveRecord::Migration[6.0]
  def change
    remove_column :whitehall_migrations,
                  :start_time,
                  :datetime
  end
end
