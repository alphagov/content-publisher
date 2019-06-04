# frozen_string_literal: true

module Requirements
  class ScheduledDatetimeChecker
    attr_reader :params

    DATE_FORMAT = "%d-%m-%Y"
    TIME_FORMAT = "%l:%M%P"
    MAXIMUM_FUTURE_TIME_PERIOD = { months: 14 }.freeze
    MINIMUM_FUTURE_TIME_PERIOD = { minutes: 15 }.freeze

    def initialize(params)
      @params = params
    end

    def pre_submit_issues
      issues = []

      issues += input_issues
      return CheckerIssues.new(issues) if issues.any?

      issues += scheduled_in_the_past_issues
      issues += scheduled_too_close_to_now_issues
      issues += scheduled_too_far_in_future_issues
      CheckerIssues.new(issues)
    end

    def parsed_datetime
      @parsed_datetime ||= begin
                             day, month, year = params[:date]&.values_at(:day, :month, :year)
                             Time.zone.strptime(
                               "#{day}-#{month}-#{year} #{params[:time]}",
                               "#{DATE_FORMAT} #{TIME_FORMAT}",
                             )
                           end
    end

  private

    def input_issues
      issues = []

      begin
        day, month, year = params[:date]&.values_at(:day, :month, :year)
        Date.strptime("#{day}-#{month}-#{year}", DATE_FORMAT)
      rescue ArgumentError
        issues << Issue.new(:scheduled_date, :invalid)
      end

      begin
        Time.strptime(params[:time].to_s, TIME_FORMAT)
      rescue ArgumentError
        issues << Issue.new(:scheduled_time, :invalid)
      end

      issues
    end

    def scheduled_in_the_past_issues
      return [] unless parsed_datetime < Time.current

      field = parsed_datetime.today? ? :scheduled_time : :scheduled_date
      [Issue.new(field, :in_the_past)]
    end

    def scheduled_too_close_to_now_issues
      minimum_time = Time.current.advance(MINIMUM_FUTURE_TIME_PERIOD)
      return [] unless parsed_datetime.between?(Time.current, minimum_time)

      [
        Issue.new(:scheduled_time,
                  :too_close_to_now,
                  time_period: time_period_for_issue(MINIMUM_FUTURE_TIME_PERIOD)),
      ]
    end

    def scheduled_too_far_in_future_issues
      maximum_future_time = Time.current.advance(MAXIMUM_FUTURE_TIME_PERIOD).end_of_day
      return [] unless parsed_datetime > maximum_future_time

      [
        Issue.new(:scheduled_date,
                  :too_far_in_future,
                  time_period: time_period_for_issue(MAXIMUM_FUTURE_TIME_PERIOD)),
      ]
    end

    def time_period_for_issue(time_period)
      time_period.map { |k, v| "#{v} #{k}" }.join(" & ")
    end
  end
end
