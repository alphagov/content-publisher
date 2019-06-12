# frozen_string_literal: true

class RenameScheduledPublishingDatetime < ActiveRecord::Migration[5.2]
  def change
    rename_column :metadata_revisions,
                  :scheduled_publishing_datetime,
                  :proposed_publish_time
  end
end
