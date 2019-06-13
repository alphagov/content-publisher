# frozen_string_literal: true

module Requirements
  class ScheduleDatetimeChecker
    attr_reader :params

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
                             time = parse_time(params[:time])
                             Time.current.change(
                               day: params.dig(:date, :day).to_i,
                               month: params.dig(:date, :month).to_i,
                               year: params.dig(:date, :year).to_i,
                               hour: time[:hour],
                               min: time[:minute],
                             )
                           end
    end

  private

    def input_issues
      issues = []

      begin
        day, month, year = params[:date]&.values_at(:day, :month, :year)
        Date.strptime("#{day}-#{month}-#{year}", "%d-%m-%Y")
      rescue ArgumentError
        issues << Issue.new(:schedule_date, :invalid)
      end

      time = parse_time(params[:time])
      issues << Issue.new(:schedule_time, :invalid) unless time

      issues
    end

    def scheduled_in_the_past_issues
      return [] unless parsed_datetime < Time.current

      field = parsed_datetime.today? ? :schedule_time : :schedule_date
      [Issue.new(field, :in_the_past)]
    end

    def scheduled_too_close_to_now_issues
      minimum_time = Time.current.advance(MINIMUM_FUTURE_TIME_PERIOD)
      return [] unless parsed_datetime.between?(Time.current, minimum_time)

      [
        Issue.new(:schedule_time,
                  :too_close_to_now,
                  time_period: time_period_for_issue(MINIMUM_FUTURE_TIME_PERIOD)),
      ]
    end

    def scheduled_too_far_in_future_issues
      maximum_future_time = Time.current.advance(MAXIMUM_FUTURE_TIME_PERIOD).end_of_day
      return [] unless parsed_datetime > maximum_future_time

      [
        Issue.new(:schedule_date,
                  :too_far_in_future,
                  time_period: time_period_for_issue(MAXIMUM_FUTURE_TIME_PERIOD)),
      ]
    end

    def parse_time(time)
      matches = time.to_s.match(%r{
        \A
        (?<hour>(2[0-3]|1[0-9]|0?[0-9]))
        :
        (?<minute>[0-5][0-9])
        (\s?(?<period>(am|pm)))?
        \Z
      }ix)

      return if !matches || (matches[:hour].to_i > 12 && matches[:period])

      hour = matches[:hour].to_i
      period = matches[:period]&.downcase

      hour24 = case period
               when "am"
                 hour == 12 ? 0 : hour
               when "pm"
                 hour == 12 ? hour : hour + 12
               else
                 hour
               end

      hour24 < 24 ? { hour: hour24, minute: matches[:minute].to_i } : nil
    end

    def time_period_for_issue(time_period)
      time_period.map { |k, v| "#{v} #{k}" }.join(" & ")
    end
  end
end
