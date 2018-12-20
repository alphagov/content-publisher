# frozen_string_literal: true

class ReferenceDocumentFromRevision < ActiveRecord::Migration[5.2]
  def change
    add_reference :versioned_revisions,
                  :document,
                  foreign_key: { to_table: :versioned_documents,
                                 on_delete: :restrict },
                  index: true,
                  null: false # rubocop:disable Rails/NotNullColumn
  end
end
