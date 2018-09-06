class CreateEventDocumentPublisheds < ActiveRecord::Migration[5.2]
  def change
    create_table :event_document_publisheds do |t|
      t.references :document, foreign_key: true
      t.references :user, foreign_key: true
      t.string :review_state

      t.timestamps
    end
  end
end
