class AddDocumentRefToWhitehallImports < ActiveRecord::Migration[6.0]
  def change
    add_reference :whitehall_imports,
                  :document,
                  foreign_key: { on_delete: :restrict },
                  null: true,
                  index: false
  end
end
