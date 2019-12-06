# frozen_string_literal: true

class AddDocumentRefToWhitehallImports < ActiveRecord::Migration[6.0]
  def change
    add_reference :whitehall_imports,
                  :document,
                  foreign_key: { on_delete: :cascade },
                  null: false,
                  index: true
  end
end
