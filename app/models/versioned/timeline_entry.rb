# frozen_string_literal: true

module Versioned
  # A model that is used to represent an entry in the history of a document.
  # It is intended to have information that is shown to a user and is not
  # intended as a debugging history log. It has associations to the data event
  # that caused it's entry to allow it to be re-built were needs to change.
  class TimelineEntry < ApplicationRecord
    self.table_name = "versioned_timeline_entries"

    # rubocop:disable Rails/InverseOf

    # The user that performed the action for this entry
    belongs_to :created_by,
               class_name: "User",
               optional: true,
               foreign_key: :created_by_id

    # For a content change this associates with the revision at the time,
    # not needed for a status change as the status associates to a revision
    belongs_to :revision,
               class_name: "Versioned::Revision",
               foreign_key: :revision_id,
               optional: true

    # For status changes this associates with the status that was changed,
    belongs_to :status,
               class_name: "Versioned::EditionStatus",
               foreign_key: :edition_status_id,
               optional: true
    # rubocop:enable Rails/InverseOf

    belongs_to :document,
               class_name: "Versioned::Document",
               foreign_key: :document_id,
               inverse_of: :timeline_entries

    # If the entry is associated with a particular edition this associates
    belongs_to :edition,
               class_name: "Versioned::Edition",
               foreign_key: :edition_id,
               optional: true,
               inverse_of: :timeline_entries

    # An association that provides key information to show this information
    # on the timeline.
    belongs_to :details, polymorphic: true, optional: true

    enum entry_type: { created: "created",
                       submitted: "submitted",
                       updated_content: "updated_content",
                       published: "published",
                       published_without_review: "published_without_review",
                       approved: "approved",
                       updated_tags: "updated_tags",
                       lead_image_updated: "lead_image_updated",
                       lead_image_removed: "lead_image_removed",
                       image_updated: "image_updated",
                       image_removed: "image_removed",
                       new_edition: "new_edition",
                       retired: "retired",
                       removed: "removed",
                       internal_note: "internal_note",
                       draft_discarded: "draft_discarded",
                       draft_reset: "draft_reset" }

    def self.create_for_status_change(entry_type:,
                                      status:,
                                      details: nil)
      create!(entry_type: entry_type,
              created_by: status.created_by,
              status: status,
              edition: status.edition,
              document: status.edition.document,
              details: details)
    end

    def self.create_for_revision(entry_type:,
                                 revision: nil,
                                 edition:,
                                 details: nil)
      revision = revision || edition.revision

      create!(entry_type: entry_type,
              created_by: revision.created_by,
              revision: revision,
              edition: edition,
              document: edition.document,
              details: details)
    end
  end
end
