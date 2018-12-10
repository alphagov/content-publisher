# frozen_string_literal: true

module Versioning
  class Revision < ApplicationRecord
    self.table_name = "versioned_revisions"

    # rubocop:disable Rails/InverseOf
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id
    # rubocop:enable Rails/InverseOf

    def readonly?
      !new_record?
    end
  end
end
