# frozen_string_literal: true

module Versioned
  # A revision of content for a document. This is accessed through a Revision
  # object
  class ContentRevision < ApplicationRecord
    self.table_name = "versioned_content_revisions"

    COMPARISON_IGNORE_FIELDS = %w[id created_at created_by_id].freeze

    # rubocop:disable Rails/InverseOf
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id
    # rubocop:enable Rails/InverseOf

    has_many :revisions,
             class_name: "Versioned::Revision",
             foreign_key: :content_revision_id,
             inverse_of: :content_revision,
             dependent: :restrict_with_exception

    def readonly?
      !new_record?
    end

    def title_or_fallback
      title.presence || I18n.t!("documents.untitled_document")
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
