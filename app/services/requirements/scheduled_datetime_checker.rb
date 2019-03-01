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

    def date_issues
      issues = []

      begin
        parsed_date
      rescue ArgumentError
        issues << Issue.new(:scheduled_datetime, :invalid, field: "Date")
      end

      CheckerIssues.new(issues)
    end

    def time_issues
      issues = []

      if parsed_time.nil?
        issues << Issue.new(:scheduled_datetime, :invalid, field: "Time")
      end

      CheckerIssues.new(issues)
    end

    def datetime_issues
      issues = []

      if in_the_past?
        issues << Issue.new(:scheduled_datetime, :in_the_past)
      end

      if too_far_in_the_future?
        issues << Issue.new(:scheduled_datetime,
                            :too_far_in_future,
                            time_period: time_period_for_issue(MAXIMUM_FUTURE_TIME_PERIOD))
      end

      if !in_the_past? && too_close_to_now?
        issues << Issue.new(:scheduled_datetime,
                            :too_close_to_now,
                            time_period: time_period_for_issue(MINIMUM_FUTURE_TIME_PERIOD))
      end

      CheckerIssues.new(issues)
    end

    def pre_submit_issues
      issues = []
      issues += date_issues.to_a
      issues += time_issues.to_a
      if date_issues.items.empty? && time_issues.items.empty?
        issues += datetime_issues.to_a
      end
      CheckerIssues.new(issues)
    end

    def parsed_datetime
      @parsed_datetime ||= DateTime.parse("#{parsed_date} #{parsed_time}").in_time_zone
    end

  private

    def parsed_date
      @parsed_date ||= Date.parse("#{year}-#{month}-#{day}")
    end

    def parsed_time
      @parsed_time ||= Time.zone.parse(time)
    end

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
