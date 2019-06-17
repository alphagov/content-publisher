# frozen_string_literal: true

class ScheduledPublishingFailedService
  def call(edition_id)
    edition = nil

    Edition.transaction do
      edition = Edition.lock.find_current(id: edition_id)
      update_status(edition)
    end

    notify_editors(edition)
  end

private

  def update_status(edition)
    raise "Expected edition to be scheduled" unless edition.scheduled?

    edition.assign_status(:failed_to_publish,
                          edition.status.created_by,
                          update_last_edited: false,
                          status_details: edition.status.details)

    edition.save!
  end

  def notify_editors(edition)
    edition.editors.each do |editor|
      ScheduledPublishMailer.failure_email(editor, edition, edition.status)
                            .deliver_later
    end
  end
end
