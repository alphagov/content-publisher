# frozen_string_literal: true

module Requirements
  class BackdateChecker
    EARLIEST_DATE = Date.new(1995, 1, 1)

    def pre_update_issues(backdate)
      issues = CheckerIssues.new

      if backdate > Time.zone.today
        issues.create(:backdate_date, :in_the_future)
      end

      if backdate < EARLIEST_DATE
        date = EARLIEST_DATE.strftime("%-d %B %Y")
        issues.create(:backdate_date, :too_long_ago, date: date)
      end

      issues
    end
  end
end
