module Requirements
  class WithdrawalChecker
    attr_reader :edition

    def initialize(edition)
      @edition = edition
    end

    def pre_withdrawal_issues(public_explanation)
      issues = CheckerIssues.new

      if public_explanation.blank?
        issues.create(:public_explanation, :blank)
      end

      unless GovspeakDocument.new(public_explanation, edition).valid?
        issues.create(:public_explanation, :invalid_govspeak)
      end

      issues
    end
  end
end
