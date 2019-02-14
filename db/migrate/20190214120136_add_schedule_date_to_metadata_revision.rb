# frozen_string_literal: true

class AddScheduleDateToMetadataRevision < ActiveRecord::Migration[5.2]
  def change
    add_column :metadata_revisions, :scheduled_publishing_datetime, :datetime
  end
end
