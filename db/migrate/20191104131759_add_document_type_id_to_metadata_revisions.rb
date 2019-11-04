# frozen_string_literal: true

class AddDocumentTypeIdToMetadataRevisions < ActiveRecord::Migration[5.2]
  def change
    add_column :metadata_revisions, :document_type_id, :string
  end
end
