# frozen_string_literal: true

class AddWhitehallImport < ActiveRecord::Migration[5.2]
  def change
    create_table :whitehall_imports do |t|
      t.bigint :whitehall_document_id, null: false
      t.json :payload, null: false
      t.uuid :content_id, null: false
      t.string :state, null: false
      t.text :error_log
      t.timestamps
    end
  end
end
