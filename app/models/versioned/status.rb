# frozen_string_literal: true

module Versioned
  # Used to represent the user facing status of an edition. Each status an
  # edition has is stored and it must always have one.
  class Status < ApplicationRecord
    self.table_name = "versioned_statuses"

    attr_readonly :value, :revision_at_creation_id

    # rubocop:disable Rails/InverseOf
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id

    belongs_to :revision_at_creation,
               class_name: "Versioned::Revision",
               foreign_key: :revision_at_creation_id
    # rubocop:enable Rails/InverseOf

    belongs_to :edition,
               class_name: "Versioned::Edition",
               foreign_key: :edition_id,
               optional: true,
               inverse_of: :statuses

    belongs_to :details,
               polymorphic: true,
               optional: true

    has_one :status_of,
            class_name: "Versioned::Edition",
            foreign_key: :status_id,
            inverse_of: :status,
            dependent: :restrict_with_exception

    has_and_belongs_to_many :revisions,
                            class_name: "Versioned::Revision",
                            join_table: "versioned_revision_statuses"

    enum state: { draft: "draft",
                  submitted_for_review: "submitted_for_review",
                  published: "published",
                  published_but_needs_2i: "published_but_needs_2i",
                  retired: "retired",
                  removed: "removed",
                  discarded: "discarded",
                  superseded: "superseded" }
  end
end
