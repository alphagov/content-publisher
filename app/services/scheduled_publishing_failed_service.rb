# frozen_string_literal: true

class ScheduledPublishingFailedService < ApplicationService
  def initialize(edition_id)
    @edition_id = edition_id
  end

  def call
    edition = nil

    Edition.transaction do
      edition = Edition.lock.find_current(id: edition_id)
      update_status(edition)
      create_timeline_entry(edition)
    end

    notify_editors(edition)
  end

private

  attr_reader :edition_id

  def update_status(edition)
    raise "Expected edition to be scheduled" unless edition.scheduled?

    edition.assign_status(:failed_to_publish,
                          edition.status.created_by,
                          update_last_edited: false,
                          status_details: edition.status.details)

    edition.save!
  end

  def create_timeline_entry(edition)
    TimelineEntry.create_for_status_change(
      entry_type: :scheduled_publishing_failed,
      status: edition.status,
    )
  end

  def notify_editors(edition)
    edition.editors.each do |editor|
      ScheduledPublishMailer.failure_email(editor, edition, edition.status)
                            .deliver_later
    end
  end
end
