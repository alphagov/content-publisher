# frozen_string_literal: true

# Stores the specific data for a removed status.
#
# This model is immutable
class Removal < ApplicationRecord
  has_one :status, as: :details

  def readonly?
    !new_record?
  end
end
