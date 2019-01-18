# frozen_string_literal: true

class UniqueIndexOnRevisionImages < ActiveRecord::Migration[5.2]
  def change
    add_index :versioned_revision_images,
              %i[revision_id image_id],
              unique: true
  end
end
