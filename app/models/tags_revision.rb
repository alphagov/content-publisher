# This stores the tags of a revision, which are grouped associations to other
# GOV.UK content by a particular tag (such as organisations).
#
# This model is immutable.
class TagsRevision < ApplicationRecord
  validates :tags, "tags_revision/tags" => true

  belongs_to :created_by, class_name: "User", optional: true

  scope :tag_contains, lambda { |tag, value|
    where("exists(select 1 from json_array_elements(tags_revisions.tags->?) " \
          "where array_to_json(array[value])->>0 = ?)", tag, value)
  }

  scope :primary_organisation_is, lambda { |org_id|
    tag_contains(:primary_publishing_organisation, org_id)
  }

  scope :tagged_organisations_include, lambda { |org_id|
    primary_organisation_is(org_id).or(tag_contains(:organisations, org_id))
  }

  def readonly?
    !new_record?
  end

  def primary_publishing_organisation_id
    tags["primary_publishing_organisation"].to_a.first
  end

  def supporting_organisation_ids
    tags["organisations"].to_a
  end
end
