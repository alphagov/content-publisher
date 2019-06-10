# frozen_string_literal: true

class ScheduledPublishingJob < ApplicationJob
  # retry at 3s, 18s, 83s, 258s, 627s
  retry_on(StandardError, wait: :exponentially_longer, attempts: 5) do |job|
    edition = Edition.find_current(id: job.arguments.first)
    send_failure_notifications(edition)
  end

  discard_and_log(ActiveRecord::RecordNotFound)

  def perform(id)
    edition = nil

    Edition.transaction do
      edition = Edition.lock.find_current(id: id)
      return unless publishable?(edition)

      user = edition.status.created_by
      reviewed = edition.status.details.reviewed
      PublishService.new(edition)
                    .publish(user: user, with_review: reviewed)
    end

    send_success_notifications(published_edition)
  end

  def self.send_failure_notifications(edition)
    edition.editors.each do |editor|
      ScheduledPublishMailer.failure_email(edition, editor).deliver_later
    end
  end

  private_class_method :send_failure_notifications

private

  def publishable?(edition)
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

  def send_success_notifications(edition)
    edition.editors.each do |editor|
      ScheduledPublishMailer.success_email(edition, editor).deliver_later
    end
  end
end
