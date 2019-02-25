# frozen_string_literal: true

# Stores the specific data for a scheduled status.
#
# This model is immutable
class Scheduling < ApplicationRecord
  has_one :status, as: :details

  belongs_to :pre_scheduled_status, class_name: "Status"

  def readonly?
    !new_record?
  end
end
