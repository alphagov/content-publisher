# frozen_string_literal: true

class AddNotNullConstraintOnDocumentTypeId < ActiveRecord::Migration[5.2]
  def change
    change_column_null(:metadata_revisions, :document_type_id, false)
  end
end
