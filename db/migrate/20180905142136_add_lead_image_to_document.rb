# frozen_string_literal: true

class AddLeadImageToDocument < ActiveRecord::Migration[5.2]
  def change
    add_reference :documents, :lead_image, foreign_key: { to_table: :images }
  end
end
