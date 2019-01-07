# frozen_string_literal: true

class AddSupersededByToVersionedAssetManagerFiles < ActiveRecord::Migration[5.2]
  def change
    add_reference :versioned_asset_manager_files,
                  :superseded_by,
                  foreign_key: { to_table: :versioned_asset_manager_files,
                                 on_delete: :nullify },
                  index: false,
                  null: true
  end
end
