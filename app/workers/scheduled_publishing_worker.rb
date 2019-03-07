# frozen_string_literal: true

class ScheduledPublishingWorker
  include Sidekiq::Worker
  # We want to retry for up to 5 minutes. 10 retries x 30s intervals = 5 minutes.
  sidekiq_options retry: 10
  sidekiq_retry_in { 30 }

  def perform(id)
    Edition.transaction do
      edition = Edition.lock.find_by(id: id, current: true)
      if edition.nil?
        logger.warn("Could not find edition id #{id} for scheduled publishing")
        return
      end

      unless edition.scheduled?
        logger.warn("Cannot schedule an edition that is not in a scheduled state")
        return
      end

      if scheduled_publishing_datetime_in_the_future?(edition)
        logger.warn("Cannot schedule an edition whose scheduled publishing datetime is in the future")
        return
      end

      user = edition.status.created_by
      reviewed = edition.status.details.reviewed

      PublishService.new(edition.document)
                    .publish(user: user, with_review: reviewed)
    end
  end

private

  def scheduled_publishing_datetime_in_the_future?(edition)
    edition.scheduled_publishing_datetime >= Time.current
  end
end
