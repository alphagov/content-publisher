# frozen_string_literal: true

module Requirements
  class BackdateChecker
    EARLIEST_DATE = Date.new(1995, 1, 1)

    def initialize(backdate)
      @backdate = backdate
    end

    def pre_submit_issues
      issues = CheckerIssues.new

      if in_the_future?
        issues << Issue.new(:backdate_date, :in_the_future)
      end

      if too_long_ago?
        date = EARLIEST_DATE.strftime("%-d %B %Y")
        issues << Issue.new(:backdate_date, :too_long_ago, date: date)
      end

      issues
    end

  private

    attr_reader :backdate

    def in_the_future?
      backdate > Time.zone.today
    end

    def too_long_ago?
      backdate < EARLIEST_DATE
    end
  end
end
