# frozen_string_literal: true

class CreateVersionedAssetManagerFile < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_asset_manager_files do |t|
      t.string :file_url
      t.string :state, null: false, default: "absent"
      t.timestamps

      t.index :file_url, unique: true
    end
  end
end
