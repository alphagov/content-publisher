# frozen_string_literal: true

class FixDocumentContentsDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :documents, :contents, {}
  end
end
