# frozen_string_literal: true

class DateParser
  def initialize(date:, issue_prefix:)
    @raw_date = date.to_h
    @issue_prefix = issue_prefix
  end

  def issues
    Requirements::CheckerIssues.new(issue_items)
  end

  def parse
    @issue_items = []

    check_date_is_valid
    issue_items.any? ? return : parsed_date
  end

private

  attr_reader :raw_date, :issue_prefix, :issue_items

  def check_date_is_valid
    parsed_date
  rescue ArgumentError
    field_name = "#{issue_prefix}_date".to_sym
    issue_items << Requirements::Issue.new(field_name, :invalid)
  end

  def parsed_date
    day, month, year = raw_date.values_at(:day, :month, :year)
    @parsed_date ||= Date.strptime("#{day}-#{month}-#{year}", "%d-%m-%Y")
  end
end
