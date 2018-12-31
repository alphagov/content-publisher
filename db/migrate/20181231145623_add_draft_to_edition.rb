# frozen_string_literal: true

class AddDraftToEdition < ActiveRecord::Migration[5.2]
  def change
    add_column :versioned_editions,
               :draft,
               :string,
               null: false # rubocop:disable Rails/NotNullColumn
  end
end
