class AddNotNullConstraintToRemovedAt < ActiveRecord::Migration[6.0]
  def change
    change_column_null :removals, :removed_at, false
  end
end
