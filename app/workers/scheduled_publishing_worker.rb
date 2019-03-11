# frozen_string_literal: true

class ScheduledPublishingWorker
  include Sidekiq::Worker
  # We want to retry for up to 5 minutes. 10 retries x 30s intervals = 5 minutes.
  sidekiq_options retry: 10
  sidekiq_retry_in { 30 }

  def perform(id)
    Edition.transaction do
      edition = Edition.lock.find_by!(id: id, current: true)
      check_edition_scheduled_and_publishable(edition)

      user = edition.status.created_by
      reviewed = edition.status.details.reviewed

      PublishService.new(edition.document)
                    .publish(user: user, with_review: reviewed)
    end
  rescue ActiveRecord::RecordNotFound
    raise AbortWorkerError, "Could not find edition id #{id} for scheduled publishing"
  end

private

  def check_edition_scheduled_and_publishable(edition)
    unless edition.scheduled?
      raise AbortWorkerError, "Cannot schedule an edition that is not in a scheduled state"
    end

    scheduled_in_future = edition.scheduled_publishing_datetime > Time.current

    if scheduled_in_future
      raise AbortWorkerError, "Cannot publish an edition whose scheduled publishing datetime is in the future"
    end
  end
end
