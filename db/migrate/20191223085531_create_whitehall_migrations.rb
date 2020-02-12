class CreateWhitehallMigrations < ActiveRecord::Migration[6.0]
  def change
    create_table :whitehall_migrations do |t|
      t.text :organisation_slug, null: false
      t.text :document_type, null: false
      t.datetime :start_time
      t.datetime :end_time
      t.timestamps
    end

    change_table :whitehall_imports, bulk: true do |t|
      t.column :whitehall_migration_id, :bigint
    end

    add_foreign_key :whitehall_imports, :whitehall_migrations
  end
end
