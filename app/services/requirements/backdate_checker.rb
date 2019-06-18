# frozen_string_literal: true

module Requirements
  class BackdateChecker
    attr_reader :params

    def initialize(params)
      @params = params
    end

    def pre_submit_issues
      issues = []

      begin
        parsed_date
      rescue ArgumentError
        issues << Issue.new(:backdate_date, :invalid)
        return CheckerIssues.new(issues)
      end

      if in_the_future?
        issues << Issue.new(:backdate_date, :in_the_future)
      end

      CheckerIssues.new(issues)
    end

    def parsed_date
      @parsed_date ||= begin
                         day, month, year = params.values_at(:day,
                                                             :month,
                                                             :year)
                         Date.strptime("#{day}-#{month}-#{year}", "%d-%m-%Y")
                       end
    end

  private

    def in_the_future?
      parsed_date > Time.zone.today
    end
  end
end
