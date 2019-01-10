# frozen_string_literal: true

class CreateVersionedRetirement < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_retirements do |t|
      t.string :explanatory_note

      t.datetime :created_at, null: false
    end
  end
end
