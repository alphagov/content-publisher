# frozen_string_literal: true

class AddBackdatedToToMetadataRevision < ActiveRecord::Migration[5.2]
  def change
    add_column :metadata_revisions, :backdated_to, :datetime
  end
end
