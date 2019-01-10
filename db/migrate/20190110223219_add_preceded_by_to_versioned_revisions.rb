# frozen_string_literal: true

class AddPrecededByToVersionedRevisions < ActiveRecord::Migration[5.2]
  def change
    add_reference :versioned_revisions,
                  :preceded_by,
                  foreign_key: { on_delete: :nullify,
                                 to_table: :versioned_revisions },
                  null: true
  end
end
