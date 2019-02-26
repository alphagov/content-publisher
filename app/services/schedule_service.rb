# frozen_string_literal: true

class ScheduleService
  attr_reader :edition

  def initialize(edition)
    @edition = edition
  end

  def schedule(user: nil, reviewed: false)
    scheduling = Scheduling.new(pre_scheduled_status: edition.status, reviewed: reviewed)
    edition.assign_status(:scheduled, user, status_details: scheduling)
    edition.save!
  end
end
