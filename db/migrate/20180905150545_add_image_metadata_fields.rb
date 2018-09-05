# frozen_string_literal: true

class AddImageMetadataFields < ActiveRecord::Migration[5.2]
  def change
    change_table :images, bulk: true do |t|
      t.string :caption
      t.string :alt_text
      t.string :credit
    end
  end
end
