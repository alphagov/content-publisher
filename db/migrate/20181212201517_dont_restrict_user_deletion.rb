# frozen_string_literal: true

class DontRestrictUserDeletion < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :versioned_documents, column: :created_by_id
    add_foreign_key :versioned_documents, :users, column: :created_by_id, on_delete: :nullify
    remove_foreign_key :versioned_editions, column: :created_by_id
    add_foreign_key :versioned_editions, :users, column: :created_by_id, on_delete: :nullify
    remove_foreign_key :versioned_revisions, column: :created_by_id
    add_foreign_key :versioned_revisions, :users, column: :created_by_id, on_delete: :nullify
  end

  def down
    remove_foreign_key :versioned_documents, column: :created_by_id
    add_foreign_key :versioned_documents, :users, column: :created_by_id, on_delete: :restrict
    remove_foreign_key :versioned_editions, column: :created_by_id
    add_foreign_key :versioned_editions, :users, column: :created_by_id, on_delete: :restrict
    remove_foreign_key :versioned_revisions, column: :created_by_id
    add_foreign_key :versioned_revisions, :users, column: :created_by_id, on_delete: :restrict
  end
end
