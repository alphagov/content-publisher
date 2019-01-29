# frozen_string_literal: true

# This stores the data for an Image::Revision about the image such as
# alt_text caption. This is distinct from Image::FileRevision as it is data
# that when changed doesn't require changing the files on Asset Manager.
#
# This model is immutable
class Image::MetadataRevision < ApplicationRecord
  COMPARISON_IGNORE_FIELDS = %w[id created_at created_by_id].freeze

  belongs_to :created_by, class_name: "User", optional: true

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
