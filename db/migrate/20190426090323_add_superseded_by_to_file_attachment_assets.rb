# frozen_string_literal: true

class AddSupersededByToFileAttachmentAssets < ActiveRecord::Migration[5.2]
  def change
    add_reference :file_attachment_assets,
      :superseded_by,
      foreign_key: { to_table: :file_attachment_assets,
                     on_delete: :restrict },
                     index: false,
                     null: true
  end
end
