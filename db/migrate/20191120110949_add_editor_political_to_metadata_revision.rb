# frozen_string_literal: true

class AddEditorPoliticalToMetadataRevision < ActiveRecord::Migration[5.2]
  def change
    add_column :metadata_revisions, :editor_political, :boolean
  end
end
