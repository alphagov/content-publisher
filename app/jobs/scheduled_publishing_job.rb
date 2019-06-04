# frozen_string_literal: true

class ScheduledPublishingJob < ApplicationJob
  # retry at 3s, 18s, 83s, 258s, 627s
  retry_on(StandardError,
           wait: :exponentially_longer,
           attempts: 5)

  discard_and_log(ActiveRecord::RecordNotFound)

  def perform(id)
    published_edition = Edition.find_and_lock_current(id: id) do |edition|
      return if no_longer_schedulable?(edition) # rubocop:disable Lint/NonLocalExitFromIterator

      user = edition.status.created_by
      reviewed = edition.status.details.reviewed
      PublishService.new(edition)
                    .publish(user: user, with_review: reviewed)
    end

    ScheduledPublishMailer.success_email(published_edition, user).deliver_later
  end

private

  def no_longer_schedulable?(edition)
    unless edition.scheduled?
      Rails.logger.warn("Cannot publish an edition (\##{edition.id}) that is not scheduled")
      return true
    end

    schedule = edition.scheduled_publishing_datetime

    if schedule > Time.zone.now
      Rails.logger.warn("Cannot publish an edition (\##{edition.id}) scheduled in the future")
      return true
    end
  end
end
