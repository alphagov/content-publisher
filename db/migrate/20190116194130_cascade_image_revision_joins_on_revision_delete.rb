# frozen_string_literal: true

class CascadeImageRevisionJoinsOnRevisionDelete < ActiveRecord::Migration[5.2]
  def up
    remove_foreign_key :versioned_revision_image_revisions,
                       column: :revision_id

    add_foreign_key :versioned_revision_image_revisions,
                    :versioned_revisions,
                    column: :revision_id,
                    on_delete: :cascade
  end

  def down
    remove_foreign_key :versioned_revision_image_revisions,
                       column: :revision_id

    add_foreign_key :versioned_revision_image_revisions,
                    :versioned_revisions,
                    column: :revision_id,
                    on_delete: :restrict
  end
end
