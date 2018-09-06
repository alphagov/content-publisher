class CreateEventDocumentSubmitteds < ActiveRecord::Migration[5.2]
  def change
    create_table :event_document_submitteds do |t|
      t.references :document, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
