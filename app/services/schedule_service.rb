# frozen_string_literal: true

class ScheduleService
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def schedule(user: nil, reviewed: false)
    scheduling = Scheduling.new(pre_scheduled_status: edition.status,
                                reviewed: reviewed)

    set_edition_status(scheduling, user)
    create_timeline_entry(:scheduled, scheduling)

    create_publish_intent
    schedule_to_publish
  end

  def reschedule(user: nil)
    unless edition.scheduled?
      raise "Edition must be scheduled in order to reschedule"
    end

    scheduling = edition.status.details
    set_edition_status(scheduling, user)
    create_timeline_entry(:schedule_updated, scheduling)

    update_publish_intent
    schedule_to_publish
  end

private

  def set_edition_status(scheduling, user)
    edition.assign_status(:scheduled, user, status_details: scheduling)
    edition.save!
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

  def schedule_to_publish
    datetime = edition.scheduled_publishing_datetime
    ScheduledPublishingJob.set(wait_until: datetime).perform_later(edition.id)
  end
end
