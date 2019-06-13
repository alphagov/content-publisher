# frozen_string_literal: true

class ScheduleService
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def schedule(reviewed:, user: nil)
    scheduling = Scheduling.new(pre_scheduled_status: edition.status,
                                reviewed: reviewed,
                                publish_time: edition.proposed_publish_time)

    update_edition(scheduling, user)
    create_timeline_entry(:scheduled, scheduling)

    create_publish_intent
    schedule_to_publish(scheduling)
  end

  def reschedule(publish_time:, user: nil)
    unless edition.scheduled?
      raise "Edition must be scheduled in order to reschedule"
    end

    previous_scheduling = edition.status.details
    new_scheduling = previous_scheduling.dup.tap { |s| s.publish_time = publish_time }

    update_edition(new_scheduling, user)
    create_timeline_entry(:schedule_updated, new_scheduling)

    update_publish_intent
    schedule_to_publish(new_scheduling)
  end

private

  def update_edition(scheduling, user)
    updater = Versioning::RevisionUpdater.new(edition.revision, user)
    updater.assign(proposed_publish_time: nil)

    edition.assign_revision(updater.next_revision, user)
           .assign_status(:scheduled, user, status_details: scheduling)
           .save!
  end

  def create_timeline_entry(entry_type, scheduling)
    TimelineEntry.create_for_status_change(
      entry_type: entry_type,
      status: edition.status,
      details: scheduling,
    )
  end

  def create_publish_intent
    payload = PublishingApiPayload.new(edition).intent_payload
    GdsApi.publishing_api.put_intent(edition.base_path, payload)
  end

  alias_method :update_publish_intent, :create_publish_intent

  def schedule_to_publish(scheduling)
    ScheduledPublishingJob.set(wait_until: scheduling.publish_time)
                          .perform_later(edition.id)
  end
end
