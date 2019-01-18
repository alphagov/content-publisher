# frozen_string_literal: true

class RemovePublishingApiSync < ActiveRecord::Migration[5.2]
  def change
    remove_column :versioned_edition_statuses,
                  :publishing_api_sync,
                  :string,
                  null: false
  end
end
