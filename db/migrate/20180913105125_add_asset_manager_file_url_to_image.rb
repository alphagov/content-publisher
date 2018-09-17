# frozen_string_literal: true

class AddAssetManagerFileUrlToImage < ActiveRecord::Migration[5.2]
  def change
    add_column :images, :asset_manager_file_url, :string
  end
end
