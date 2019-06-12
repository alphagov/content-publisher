# frozen_string_literal: true

module Requirements
  class ScheduleChecker
    include ActionView::Helpers::DateHelper

    attr_reader :revision

    MAX_PUBLISH_DELAY = 14.months
    MIN_PUBLISH_DELAY = 15.minutes

    def initialize(revision)
      @revision = revision
    end

    def pre_schedule_issues
      issues = []

      if publish_at > MAX_PUBLISH_DELAY.from_now
        issues << Issue.new(:schedule_date,
                            :too_far_in_future,
                            time_period: MAX_PUBLISH_DELAY.inspect)
      end

      if publish_at > Time.current && publish_at < MIN_PUBLISH_DELAY.from_now
        issues << Issue.new(:schedule_time,
                            :too_close_to_now,
                            time_period: MIN_PUBLISH_DELAY.inspect)
      end

      if publish_at < Time.current
        field = publish_at.today? ? :schedule_time : :schedule_date
        issues << Issue.new(field, :in_the_past)
      end

      CheckerIssues.new(issues)
    end

  private

    def publish_at
      @publish_at ||= revision.scheduled_publishing_datetime
    end
  end
end
