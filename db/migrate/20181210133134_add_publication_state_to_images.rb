# frozen_string_literal: true

class AddPublicationStateToImages < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :publication_state, :string, null: false # rubocop:disable Rails/NotNullColumn
  end
end
