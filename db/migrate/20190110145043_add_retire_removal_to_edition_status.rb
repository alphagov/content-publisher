# frozen_string_literal: true

class AddRetireRemovalToEditionStatus < ActiveRecord::Migration[5.2]
  def change
    add_reference :versioned_edition_statuses,
                  :details,
                  polymorphic: true,
                  null: true
  end
end
