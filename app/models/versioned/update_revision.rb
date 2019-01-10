# frozen_string_literal: true

module Versioned
  # A revision of update information (change note, update type) for a document.
  # This is accessed through a Revision object
  class UpdateRevision < ApplicationRecord
    self.table_name = "versioned_update_revisions"

    COMPARISON_IGNORE_FIELDS = %w[id created_at created_by_id].freeze

    # rubocop:disable Rails/InverseOf
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id
    # rubocop:enable Rails/InverseOf

    has_many :revisions,
             class_name: "Versioned::Revision",
             foreign_key: :update_revision_id,
             inverse_of: :update_revision,
             dependent: :restrict_with_exception

    enum update_type: { major: "major", minor: "minor" }

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
