# frozen_string_literal: true

# Represents an access limit which applies to an edition that is not live
#
# This model is immutable
class AccessLimit < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true

  belongs_to :edition

  belongs_to :revision_at_creation, class_name: "Revision"

  enum limit_type: { primary_organisation: "primary_organisation",
                     all_organisations: "all_organisations" }

  def readonly?
    !new_record?
  end
end
