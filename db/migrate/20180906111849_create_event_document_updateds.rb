class CreateEventDocumentUpdateds < ActiveRecord::Migration[5.2]
  def change
    create_table :event_document_updateds do |t|
      t.references :document, foreign_key: true
      t.references :user, foreign_key: true
      t.json :before, default: {}
      t.json :after, default: {}
      t.json :changeset, default: {}

      t.timestamps
    end
  end
end
