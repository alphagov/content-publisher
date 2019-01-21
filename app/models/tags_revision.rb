# frozen_string_literal: true

# A revision of tags for a document.
# This is accessed through a Revision object
class TagsRevision < ApplicationRecord
  self.table_name = "versioned_tags_revisions"

  COMPARISON_IGNORE_FIELDS = %w[id created_at created_by_id].freeze

  belongs_to :created_by, class_name: "User", optional: true

  has_many :revisions, inverse_of: :tags_revision, dependent: :restrict_with_exception

  def readonly?
    !new_record?
  end

  def build_revision_update(attributes, user)
    new_revision = dup.tap { |d| d.assign_attributes(attributes) }
    return self unless different_to?(new_revision)

    new_revision.tap { |r| r.created_by = user }
  end

  def different_to?(other_revision)
    other_attributes = other_revision.attributes.except(*COMPARISON_IGNORE_FIELDS)
    attributes.except(*COMPARISON_IGNORE_FIELDS) != other_attributes
  end
end
