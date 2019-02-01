# frozen_string_literal: true

module Requirements
  class WithdrawalChecker
    attr_reader :public_explanation

    def initialize(public_explanation)
      @public_explanation = public_explanation
    end

    def pre_withdrawal_issues
      issues = []

      if public_explanation.blank?
        issues << Issue.new(:public_explanation, :blank)
      end

      CheckerIssues.new(issues)
    end
  end
end
