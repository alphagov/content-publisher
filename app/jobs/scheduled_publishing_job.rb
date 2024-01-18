class ScheduledPublishingJob < ApplicationJob
  # retry at 3s, 18s, 83s, 258s, 627s
  retry_on(StandardError, wait: :polynomially_longer, attempts: 5) do |job, error|
    GovukError.notify(error)
    RescueScheduledPublishingService.call(edition_id: job.arguments.first)
  end

  discard_and_log(ActiveRecord::RecordNotFound)

  def perform(id)
    edition = nil

    Edition.transaction do
      edition = Edition.lock.find_current(id:)
      return unless expected_state?(edition)

      user = edition.status.created_by
      reviewed = edition.status.details.reviewed
      PublishDraftEditionService.call(edition, user, with_review: reviewed)
      create_timeline_entry(edition, reviewed)
    end

    notify_editors(edition)
  end

private

  def create_timeline_entry(edition, reviewed)
    entry_type = if reviewed
                   :scheduled_publishing_succeeded
                 else
                   :scheduled_publishing_without_review_succeeded
                 end

    TimelineEntry.create_for_status_change(entry_type:, status: edition.status)
  end

  def expected_state?(edition)
    unless edition.scheduled?
      Rails.logger.warn("Cannot publish an edition (\##{edition.id}) that is not scheduled")
      return false
    end

    scheduling = edition.status.details

    if scheduling.publish_time > Time.zone.now
      Rails.logger.warn("Cannot publish an edition (\##{edition.id}) scheduled in the future")
      return false
    end

    true
  end

  def notify_editors(edition)
    edition.editors.each do |editor|
      ScheduledPublishMailer.success_email(editor, edition, edition.status)
                            .deliver_later
    end
  end
end
