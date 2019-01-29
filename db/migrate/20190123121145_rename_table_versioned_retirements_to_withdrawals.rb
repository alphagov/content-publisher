# frozen_string_literal: true

class RenameTableVersionedRetirementsToWithdrawals < ActiveRecord::Migration[5.2]
  def change
    rename_table :versioned_retirements, :withdrawals
  end
end
