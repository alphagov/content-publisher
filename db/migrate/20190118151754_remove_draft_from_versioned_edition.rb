# frozen_string_literal: true

class RemoveDraftFromVersionedEdition < ActiveRecord::Migration[5.2]
  def change
    remove_column :versioned_editions,
                  :draft,
                  :string,
                  null: false
  end
end
