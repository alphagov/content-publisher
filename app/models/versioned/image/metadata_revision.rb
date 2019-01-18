# frozen_string_literal: true

module Versioned
  # This stores the data for an Image::Revision about the image such as
  # alt_text caption. This is distinct from Image::FileRevision as it is data
  # that when changed doesn't require changing the files on Asset Manager.
  #
  # This model is immutable
  class Image::MetadataRevision < ApplicationRecord
    self.table_name = "versioned_image_metadata_revisions"

    COMPARISON_IGNORE_FIELDS = %w[id created_at created_by_id].freeze

    # rubocop:disable Rails/InverseOf
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id
    # rubocop:enable Rails/InverseOf

    has_many :revisions,
             class_name: "Versioned::Image::Revision",
             foreign_key: :image_revision_id,
             inverse_of: :metadata_revision,
             dependent: :restrict_with_exception

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
end
