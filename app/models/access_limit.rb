# frozen_string_literal: true

# Represents an access limit which applies to an edition that is not live
#
# This model is immutable
class AccessLimit < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true

  belongs_to :edition

  belongs_to :revision_at_creation, class_name: "Revision"

  enum limit_type: { primary_organisation: "primary_organisation",
                     tagged_organisations: "tagged_organisations" }

  def readonly?
    !new_record?
  end

  def organisation_ids
    orgs = [edition.primary_publishing_organisation_id]
    orgs += edition.supporting_organisation_ids if tagged_organisations?
    orgs
  end
end
