class AddAuthBypassIdToEditions < ActiveRecord::Migration[6.0]
  def change
    add_column :editions, :auth_bypass_id, :uuid
  end
end
