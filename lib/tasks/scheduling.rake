namespace :scheduling do
  desc "Re-populate all the scheduling jobs in Sidekiq"
  task repopulate: :environment do
    scheduled_scope = Edition.joins(:status)
                             .merge(Status.scheduled)
                             .where(current: true)

    scheduled_scope.find_each do |edition|
      scheduling = edition.status.details
      ScheduledPublishingJob.set(wait_until: scheduling.publish_time)
                            .perform_later(edition.id)
    end
  end
end
