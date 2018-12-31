# frozen_string_literal: true

class UpdateTypeNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :versioned_revisions, :update_type, false
  end
end
