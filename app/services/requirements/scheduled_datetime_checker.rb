# frozen_string_literal: true

module Requirements
  class ScheduledDatetimeChecker
    attr_reader :day, :month, :year, :time

    MAXIMUM_FUTURE_TIME_PERIOD = { months: 14 }.freeze
    MINIMUM_FUTURE_TIME_PERIOD = { minutes: 15 }.freeze

    def initialize(params)
      @day = params[:day]
      @month = params[:month]
      @year = params[:year]
      @time = params[:time]
    end

    def pre_submit_issues
      issues = []

      if day.blank? || month.blank? || year.blank?
        issues << Issue.new(:scheduled_datetime, :invalid, field: "date")
      end

      if time.blank?
        issues << Issue.new(:scheduled_datetime, :invalid, field: "time")
      end

      if issues.any?
        return CheckerIssues.new(issues)
      end

      if in_the_past?
        issues << Issue.new(:scheduled_datetime, :in_the_past)
        return CheckerIssues.new(issues)
      end

      if too_far_in_the_future?
        issues << Issue.new(:scheduled_datetime,
                            :too_far_in_future,
                            time_period: time_period_for_issue(MAXIMUM_FUTURE_TIME_PERIOD))
      end

      if too_close_to_now?
        issues << Issue.new(:scheduled_datetime,
                            :too_close_to_now,
                            time_period: time_period_for_issue(MINIMUM_FUTURE_TIME_PERIOD))
      end

      CheckerIssues.new(issues)
    end

    def parsed_datetime
      @parsed_datetime ||= Time.zone.parse("#{year}-#{month}-#{day} #{time}")
    end

  private

    def in_the_past?
      now = Time.zone.now
      parsed_datetime <= now
    end

    def too_far_in_the_future?
      now = Time.zone.now
      parsed_datetime > now.advance(MAXIMUM_FUTURE_TIME_PERIOD).end_of_day
    end

    def too_close_to_now?
      now = Time.zone.now
      parsed_datetime < now.advance(MINIMUM_FUTURE_TIME_PERIOD)
    end

    def time_period_for_issue(time_period)
      time_period.map { |k, v| "#{v} #{k}" }.join(" & ")
    end
  end
end
