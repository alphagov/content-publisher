# frozen_string_literal: true

class LastEditedAtNotNull < ActiveRecord::Migration[5.2]
  def change
    change_column_null :versioned_documents, :last_edited_at, false
    change_column_null :versioned_editions, :last_edited_at, false
  end
end
