# frozen_string_literal: true

class CreateVersionedDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :versioned_documents do |t|
      t.uuid :content_id, null: false
      t.string :locale, null: false
      t.string :document_type_id, null: false
      t.datetime :last_edited_at
      t.timestamps

      t.references :created_by,
                   foreign_key: { to_table: :users, on_delete: :restrict },
                   index: true
      t.index %i[content_id locale], unique: true
    end
  end
end
