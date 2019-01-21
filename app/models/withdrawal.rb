# frozen_string_literal: true

class Withdrawal < ApplicationRecord
  self.table_name = "versioned_retirements"

  has_one :status, as: :details

  def readonly?
    !new_record?
  end
end
