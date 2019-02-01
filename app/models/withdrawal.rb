# frozen_string_literal: true

# Stores the specific data for a withdrawn status.
#
# This model is immutable
class Withdrawal < ApplicationRecord
  has_one :status, as: :details

  belongs_to :published_status, class_name: "Status"

  def readonly?
    !new_record?
  end
end
