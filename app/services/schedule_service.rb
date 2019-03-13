# frozen_string_literal: true

class ScheduleService
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def schedule(user: nil, reviewed: false)
    scheduling = Scheduling.new(pre_scheduled_status: edition.status, reviewed: reviewed)
    set_edition_status(scheduling, user)
    create_timeline_entry(scheduling)

    create_publish_intent(edition)
  end

private

  def set_edition_status(scheduling, user)
    edition.assign_status(:scheduled, user, status_details: scheduling)
    edition.save!
  end

  def create_timeline_entry(scheduling)
    TimelineEntry.create_for_status_change(
      entry_type: :scheduled,
      status: edition.status,
      details: scheduling,
    )
  end

  def create_publish_intent(edition)
    payload = PublishingApiPayload.new(edition).intent_payload
    GdsApi.publishing_api.put_intent(edition.base_path, payload)
  end
end
