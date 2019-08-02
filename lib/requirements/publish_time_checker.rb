# frozen_string_literal: true

module Requirements
  class PublishTimeChecker
    include ActionView::Helpers::DateHelper

    attr_reader :publish_time

    MAX_PUBLISH_DELAY = 14.months
    MIN_PUBLISH_DELAY = 15.minutes

    def initialize(publish_time)
      @publish_time = publish_time
    end

    def issues
      issues = CheckerIssues.new

      if publish_time > MAX_PUBLISH_DELAY.from_now
        issues << Issue.new(:schedule_date,
                            :too_far_in_future,
                            time_period: MAX_PUBLISH_DELAY.inspect)
      end

      if publish_time > Time.current && publish_time < MIN_PUBLISH_DELAY.from_now
        issues << Issue.new(:schedule_time,
                            :too_close_to_now,
                            time_period: MIN_PUBLISH_DELAY.inspect)
      end

      if publish_time < Time.current
        field = publish_time.today? ? :schedule_time : :schedule_date
        issues << Issue.new(field, :in_the_past)
      end

      issues
    end
  end
end
