# frozen_string_literal: true

# This stores the tags of a revision, which are grouped associations to other
# GOV.UK content by a particular tag (such as organisations).
#
# This model is immutable.
class TagsRevision < ApplicationRecord
  belongs_to :created_by, class_name: "User", optional: true

  def readonly?
    !new_record?
  end
end
