class AuthBypassIdNotNull < ActiveRecord::Migration[6.0]
  def change
    change_column_null :editions, :auth_bypass_id, false
  end
end
