# frozen_string_literal: true

class ScheduledPublishingWorker
  include Sidekiq::Worker

  def perform(id)
    Edition.transaction do
      edition = Edition.lock.find_by(id: id, current: true)
      user = edition.status.created_by
      reviewed = edition.status.details.reviewed

      PublishService.new(edition.document)
                    .publish(user: user, with_review: reviewed)
    end
  end
end
