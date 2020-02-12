class RenameWhitehallMigrationsEndTime < ActiveRecord::Migration[6.0]
  def change
    rename_column :whitehall_migrations, :end_time, :finished_at
  end
end
