# frozen_string_literal: true

class TimelineEntry::WhitehallImportedEntry < ApplicationRecord
  enum entry_type: {
    archived: "archived",
    document_updated: "document_updated",
    fact_check_request: "fact_check_request",
    fact_check_response: "fact_check_response",
    first_created: "first_created",
    imported_from_whitehall: "imported_from_whitehall",
    internal_note: "internal_note",
    new_edition: "new_edition",
    published: "published",
    rejected: "rejected",
    removed: "removed",
    scheduled: "scheduled",
    submitted: "submitted",
    withdrawn: "withdrawn",
  }

  def readonly?
    !new_record?
  end
end
