# frozen_string_literal: true

class UnscheduleController < ApplicationController
  def unschedule
    Document.transaction do
      document = Document.with_current_edition.lock!.find_by_param(params[:id])
      edition = document.current_edition
      schedule = edition.status.details

      remove_scheduled_publishing_datetime(edition)

      state = schedule.reviewed? ? "submitted_for_review" : "draft"
      edition.assign_status(state, current_user)
      edition.save!

      TimelineEntry.create_for_status_change(
        entry_type: :unscheduled,
        status: edition.status,
      )

      redirect_to document_path(document)
    end
  end

private

  def remove_scheduled_publishing_datetime(edition)
    current_revision = edition.revision
    new_revision = current_revision.build_revision_update(
      { scheduled_publishing_datetime: nil }, current_user
    )

    edition.assign_revision(new_revision, current_user).save!
  end
end
