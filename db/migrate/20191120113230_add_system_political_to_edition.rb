# frozen_string_literal: true

class AddSystemPoliticalToEdition < ActiveRecord::Migration[5.2]
  def change
    add_column :editions, :system_political, :boolean, default: false, null: false
  end
end
