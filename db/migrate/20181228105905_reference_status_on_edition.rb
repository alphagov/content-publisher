# frozen_string_literal: true

class ReferenceStatusOnEdition < ActiveRecord::Migration[5.2]
  def change
    add_reference :versioned_editions,
                  :status,
                  foreign_key: { to_table: :versioned_edition_statuses,
                                 on_delete: :restrict },
                  index: true,
                  null: false # rubocop:disable Rails/NotNullColumn
  end
end
