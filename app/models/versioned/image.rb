# frozen_string_literal: true

module Versioned
  # A basic model that is used to join together a collection of image revisions
  # with the item they represent. Thus two image_revisions that link to the
  # same Image are considered two revision of that image.
  class Image < ApplicationRecord
    self.table_name = "versioned_images"

    # rubocop:disable Rails/InverseOf
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id
    # rubocop:enable Rails/InverseOf

    has_many :image_revisions,
             class_name: "Versioned::ImageRevision",
             foreign_key: :image_id,
             inverse_of: :image,
             dependent: :restrict_with_exception

    def readonly?
      !new_record?
    end
  end
end
