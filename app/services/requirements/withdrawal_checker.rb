# frozen_string_literal: true

module Requirements
  class WithdrawalChecker
    attr_reader :public_explanation, :edition

    def initialize(public_explanation, edition)
      @public_explanation = public_explanation
      @edition = edition
    end

    def pre_withdrawal_issues
      issues = CheckerIssues.new

      if public_explanation.blank?
        issues << Issue.new(:public_explanation, :blank)
      end

      unless GovspeakDocument.new(public_explanation, edition).valid?
        issues << Issue.new(:public_explanation, :invalid_govspeak)
      end

      issues
    end
  end
end
