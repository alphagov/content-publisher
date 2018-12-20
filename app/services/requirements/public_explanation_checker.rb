# frozen_string_literal: true

module Requirements
  class PublicExplanationChecker
    PUBLIC_EXPLANATION_MAX_LENGTH = 600

    attr_reader :public_explanation

    def initialize(public_explanation)
      @public_explanation = public_explanation
    end

    def pre_withdrawal_issues
      issues = []

      if public_explanation.blank?
        issues << Issue.new(:public_explanation, :blank)
      end

      if public_explanation.to_s.size > PUBLIC_EXPLANATION_MAX_LENGTH
        issues << Issue.new(:public_explanation, :too_long, max_length: PUBLIC_EXPLANATION_MAX_LENGTH)
      end

      CheckerIssues.new(issues)
    end
  end
end
