# frozen_string_literal: true

class CreateScheduling < ActiveRecord::Migration[5.2]
  def change
    create_table :schedulings do |t|
      t.boolean :reviewed, default: false
      t.datetime :created_at, null: false
      t.references :pre_scheduled_status,
                   foreign_key: { to_table: :statuses, on_delete: :restrict },
                   index: false,
                   null: false
    end
  end
end
