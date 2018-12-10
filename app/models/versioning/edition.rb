# frozen_string_literal: true

module Versioning
  class Edition < ApplicationRecord
    self.table_name = "versioned_editions"

    attr_readonly :number, :document_id

    # rubocop:disable Rails/InverseOf
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id
    # rubocop:enable Rails/InverseOf

    belongs_to :document,
               class_name: "Versioning::Document",
               inverse_of: :editions
  end
end
