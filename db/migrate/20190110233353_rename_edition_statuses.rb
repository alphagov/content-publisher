# frozen_string_literal: true

class RenameEditionStatuses < ActiveRecord::Migration[5.2]
  def change
    rename_table :versioned_edition_statuses, :versioned_statuses
  end
end
