# frozen_string_literal: true

class InternalNote < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true

  belongs_to :edition

  def readonly?
    !new_record?
  end
end
