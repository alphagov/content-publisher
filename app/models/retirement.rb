# frozen_string_literal: true

class Retirement < ApplicationRecord
  self.table_name = "versioned_retirements"

  has_one :status, as: :details, dependent: :restrict_with_exception

  def readonly?
    !new_record?
  end
end
