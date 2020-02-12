class AddGovernmentIdToEdition < ActiveRecord::Migration[5.2]
  def change
    add_column :editions, :government_id, :uuid
  end
end
