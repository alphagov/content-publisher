# frozen_string_literal: true

class DefaultDocumentTextFieldsToEmptyStrings < ActiveRecord::Migration[5.2]
  def up
    change_column_default :documents, :base_path, ""
    change_column_default :documents, :title, ""
    change_column_default :documents, :summary, ""

    change_column_null :documents, :base_path, false
    change_column_null :documents, :title, false
    change_column_null :documents, :summary, false
    change_column_null :documents, :associations, false
    change_column_null :documents, :contents, false
  end

  def down
    change_column_default :documents, :base_path, nil
    change_column_default :documents, :title, nil
    change_column_default :documents, :summary, nil

    change_column_null :documents, :base_path, true
    change_column_null :documents, :title, true
    change_column_null :documents, :summary, true
    change_column_null :documents, :associations, true
    change_column_null :documents, :contents, true
  end
end
