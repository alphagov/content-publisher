# frozen_string_literal: true

module Versioned
  class Removal < ApplicationRecord
    self.table_name = "versioned_removals"

    has_one :status,
            as: :details,
            class_name: "Versioned::Status",
            dependent: :restrict_with_exception

    def readonly?
      !new_record?
    end
  end
end
