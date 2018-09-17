# frozen_string_literal: true

class NullifyLeadImageForeignKey < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key "documents", "images"
    add_foreign_key "documents", "images", column: :lead_image_id, on_delete: :nullify
  end
end
