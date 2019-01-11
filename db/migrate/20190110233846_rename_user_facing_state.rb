# frozen_string_literal: true

class RenameUserFacingState < ActiveRecord::Migration[5.2]
  def change
    rename_column :versioned_statuses, :user_facing_state, :state
  end
end
