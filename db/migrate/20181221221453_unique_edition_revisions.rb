# frozen_string_literal: true

class UniqueEditionRevisions < ActiveRecord::Migration[5.2]
  def change
    add_index :versioned_edition_revisions,
              %i[edition_id revision_id],
              unique: true
  end
end
