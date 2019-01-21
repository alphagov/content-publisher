# frozen_string_literal: true

class Removal < ApplicationRecord
  self.table_name = "versioned_removals"

  has_one :status, as: :details, dependent: :restrict_with_exception

  def readonly?
    !new_record?
  end
end
