# frozen_string_literal: true

class AddLeadImageToVersionedRevisions < ActiveRecord::Migration[5.2]
  def change
    add_reference :versioned_revisions,
                  :lead_image,
                  foreign_key: { to_table: :versioned_images, on_delete: :restrict },
                  index: true
  end
end
