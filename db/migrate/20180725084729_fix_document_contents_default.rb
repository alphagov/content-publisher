# frozen_string_literal: true

class FixDocumentContentsDefault < ActiveRecord::Migration[5.2]
  def up
    change_column_default :documents, :contents, {}
  end

  def down
    change_column_default :documents, :contents, "{}"
  end
end
