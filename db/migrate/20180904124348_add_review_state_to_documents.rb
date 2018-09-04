# frozen_string_literal: true

class AddReviewStateToDocuments < ActiveRecord::Migration[5.2]
  def up
    execute "TRUNCATE documents CASCADE"
    add_column :documents, :review_state, :string, null: false # rubocop:disable Rails/NotNullColumn
  end

  def down
    remove_column :documents, :review_state
  end
end
