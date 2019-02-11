# frozen_string_literal: true

class AddWithdrawnAtToWithdrawal < ActiveRecord::Migration[5.2]
  def change
    add_column :withdrawals, :withdrawn_at, :datetime, null: false # rubocop:disable Rails/NotNullColumn
  end
end
