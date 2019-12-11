# frozen_string_literal: true

# A model that is used to represent an entry in the history of a document.
# It is intended to have information that is shown to a user and is not
# intended as a debugging history log. It has associations to the data event
# that caused it's entry to allow it to be re-built were needs to change.
class TimelineEntry < ApplicationRecord
  # The user that performed the action for this entry
  belongs_to :created_by, class_name: "User", optional: true

  belongs_to :document

  # If the entry is associated with a particular edition this associates
  belongs_to :edition, optional: true

  # For a content change this associates with the revision at the time,
  # not needed for a status change as the status associates to a revision
  belongs_to :revision, optional: true

  # For status changes this associates with the status that was changed,
  belongs_to :status, optional: true

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
                     lead_image_selected: "lead_image_selected",
                     lead_image_removed: "lead_image_removed",
                     image_updated: "image_updated",
                     image_deleted: "image_deleted",
                     new_edition: "new_edition",
                     withdrawn: "withdrawn",
                     withdrawn_updated: "withdrawn_updated",
                     unwithdrawn: "unwithdrawn",
                     removed: "removed",
                     internal_note: "internal_note",
                     draft_discarded: "draft_discarded",
                     draft_reset: "draft_reset",
                     scheduled: "scheduled",
                     scheduled_publishing_succeeded: "scheduled_publishing_succeeded",
                     scheduled_publishing_without_review_succeeded: "scheduled_publishing_without_review_succeeded",
                     scheduled_publishing_failed: "scheduled_publishing_failed",
                     schedule_updated: "schedule_updated",
                     unscheduled: "unscheduled",
                     file_attachment_uploaded: "file_attachment_uploaded",
                     file_attachment_deleted: "file_attachment_deleted",
                     file_attachment_updated: "file_attachment_updated",
                     backdated: "backdated",
                     backdate_cleared: "backdate_cleared",
                     access_limit_created: "access_limit_created",
                     access_limit_updated: "access_limit_updated",
                     access_limit_removed: "access_limit_removed",
                     political_status_changed: "political_status_changed" }

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

  def self.create_for_edition(entry_type:,
                              edition:,
                              created_by:,
                              details: nil)
    create!(entry_type: entry_type,
            created_by: created_by,
            edition: edition,
            document: edition.document,
            details: details)
  end

  def self.create_for_revision(entry_type:,
                               revision: nil,
                               edition:,
                               details: nil,
                               created_by: nil)

    revision = revision || edition.revision
    creator = created_by || revision.created_by

    create!(entry_type: entry_type,
            created_by: creator,
            revision: revision,
            edition: edition,
            document: edition.document,
            details: details)
  end
end
