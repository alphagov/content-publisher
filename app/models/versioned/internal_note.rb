# frozen_string_literal: true

module Versioned
  class InternalNote < ApplicationRecord
    self.table_name = "versioned_internal_notes"

    belongs_to :edition,
               class_name: "Versioned::Edition",
               foreign_key: :edition_id,
               inverse_of: :internal_notes

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
