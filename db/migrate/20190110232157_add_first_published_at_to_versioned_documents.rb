# frozen_string_literal: true

class AddFirstPublishedAtToVersionedDocuments < ActiveRecord::Migration[5.2]
  def change
    add_column :versioned_documents,
               :first_published_at,
               :datetime,
               null: true
  end
end
