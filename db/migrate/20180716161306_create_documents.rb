# frozen_string_literal: true

class CreateDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :documents do |t|
      t.string :content_id, null: false
      t.string :locale, null: false
      t.index %i[content_id locale], unique: true

      t.string :document_type
      t.string :title

      t.timestamps
    end
  end
end
