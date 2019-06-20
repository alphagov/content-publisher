# frozen_string_literal: true

module Requirements
  class BackdateChecker
    def initialize(backdate)
      @backdate = backdate
    end

    def pre_submit_issues
      issues = []

      if in_the_future?
        issues << Issue.new(:backdate_date, :in_the_future)
      end

      CheckerIssues.new(issues)
    end

  private

    attr_reader :backdate

    def in_the_future?
      backdate > Time.zone.today
    end
  end
end
