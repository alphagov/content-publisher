# frozen_string_literal: true

class AddPublishedStatusToWithdrawals < ActiveRecord::Migration[5.2]
  def change
    add_reference :withdrawals,
                  :published_status,
                  foreign_key: { to_table: :statuses, on_delete: :restrict },
                  index: false,
                  null: false # rubocop:disable Rails/NotNullColumn
  end
end
