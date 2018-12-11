# frozen_string_literal: true

module Versioning
  class Revision < ApplicationRecord
    self.table_name = "versioned_revisions"

    # rubocop:disable Rails/InverseOf
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id

    belongs_to :lead_image,
               class_name: "Versioning::Image",
               optional: true,
               foreign_key: :lead_image_id
    # rubocop:enable Rails/InverseOf

    has_many :current_for_editions,
             class_name: "Versioning::Edition",
             foreign_key: :current_revision_id,
             inverse_of: :current_revision,
             dependent: :restrict_with_exception

    has_and_belongs_to_many :editions,
                            class_name: "Versioning::Edition",
                            join_table: "versioned_edition_revisions"

    has_and_belongs_to_many :images,
                            class_name: "Versioning::Image",
                            join_table: "versioned_revision_images"

    def readonly?
      !new_record?
    end
  end
end
