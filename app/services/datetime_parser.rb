# frozen_string_literal: true

class DatetimeParser
  def initialize(date:, time:, issue_prefix:)
    @raw_date = date.to_h
    @raw_time = time.to_s
    @issue_prefix = issue_prefix
  end

  def issues
    Requirements::CheckerIssues.new(issue_items || [])
  end

  def parse
    @issue_items = []

    check_date_is_valid
    check_time_is_valid
    return if issue_items.any?

    Time.current.change(
      day: raw_date[:day].to_i,
      month: raw_date[:month].to_i,
      year: raw_date[:year].to_i,
      hour: time[:hour],
      min: time[:minute],
    )
  end

private

  attr_reader :raw_date, :raw_time, :issue_items, :issue_prefix

  def check_date_is_valid
    day, month, year = raw_date.values_at(:day, :month, :year)
    Date.strptime("#{day}-#{month}-#{year}", "%d-%m-%Y")
  rescue ArgumentError
    field_name = "#{issue_prefix}_date".to_sym
    issue_items << Requirements::Issue.new(field_name, :invalid)
  end

  def check_time_is_valid
    field_name = "#{issue_prefix}_time".to_sym

    if !parsed_time_values
      issue_items << Requirements::Issue.new(field_name, :invalid)
      return
    end

    if parsed_time_values[:hour].to_i > 12 && parsed_time_values[:period]
      issue_items << Requirements::Issue.new(field_name, :invalid)
      return
    end

    if time[:hour] > 23
      issue_items << Requirements::Issue.new(field_name, :invalid)
      return
    end
  end

  def parsed_time_values
    @parsed_time_values ||= raw_time.match(%r{
      \A
      (?<hour>(2[0-3]|1[0-9]|0?[0-9]))
      :
      (?<minute>[0-5][0-9])
      (\s?(?<period>(am|pm)))?
      \Z
    }ix)
  end

  def time
    @time ||= begin
      hour = parsed_time_values[:hour].to_i
      period = parsed_time_values[:period]&.downcase
      minute = parsed_time_values[:minute].to_i

      hour24 = case period
               when "am" then hour == 12 ? 0 : hour
               when "pm" then hour == 12 ? hour : hour + 12
               else hour
               end

      { hour: hour24, minute: minute }
    end
  end
end
