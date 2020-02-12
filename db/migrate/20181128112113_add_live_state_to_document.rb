class AddLiveStateToDocument < ActiveRecord::Migration[5.2]
  def change
    add_column :documents, :live_state, :string
  end
end
