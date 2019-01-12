# frozen_string_literal: true

class AddNumberToVersionedRevision < ActiveRecord::Migration[5.2]
  def change
    add_column :versioned_revisions,
               :number,
               :integer,
               null: false # rubocop:disable Rails/NotNullColumn
    add_index :versioned_revisions, %i[number document_id], unique: true
  end
end
