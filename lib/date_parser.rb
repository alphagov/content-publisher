# frozen_string_literal: true

class DateParser
  attr_reader :raw_date, :issue_prefix, :issues

  def initialize(date:, issue_prefix:)
    @raw_date = date.to_h
    @issue_prefix = issue_prefix
    @issues = Requirements::CheckerIssues.new
  end

  def parse
    @issues = Requirements::CheckerIssues.new
    check_date_is_valid
    parsed_date if issues.none?
  end

private

  def check_date_is_valid
    parsed_date
  rescue ArgumentError
    field_name = "#{issue_prefix}_date".to_sym
    issues << Requirements::Issue.new(field_name, :invalid)
  end

  def parsed_date
    day, month, year = raw_date.values_at(:day, :month, :year)
    @parsed_date ||= Date.strptime("#{day}-#{month}-#{year}", "%d-%m-%Y")
  end
end
