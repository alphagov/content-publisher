# frozen_string_literal: true

class UnscheduleController < ApplicationController
  def unschedule
    Edition.find_and_lock_current(document: params[:document]) do |edition|
      schedule = edition.status.details

      updater = Versioning::RevisionUpdater.new(edition.revision, current_user)
      updater.assign(scheduled_publishing_datetime: nil)
      edition.assign_revision(updater.next_revision, current_user)

      state = schedule.reviewed? ? "submitted_for_review" : "draft"
      edition.assign_status(state, current_user).save!

      TimelineEntry.create_for_status_change(entry_type: :unscheduled, status: edition.status)
      redirect_to document_path(edition.document)
    end
  end
end
