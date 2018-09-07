class CreateEventDocumentApproveds < ActiveRecord::Migration[5.2]
  def change
    create_table :event_document_approveds do |t|
      t.references :document, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
