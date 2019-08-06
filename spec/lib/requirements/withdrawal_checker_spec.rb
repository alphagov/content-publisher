# frozen_string_literal: true

RSpec.describe Requirements::WithdrawalChecker do
  describe "#pre_withdrawal_issues" do
    let(:edition) { build(:edition) }

    it "returns no issues if there are none" do
      explanation = SecureRandom.alphanumeric
      issues = Requirements::WithdrawalChecker.new(explanation, edition).pre_withdrawal_issues
      expect(issues).to be_empty
    end

    it "returns an issue if there is no public explanation" do
      issues = Requirements::WithdrawalChecker.new(nil, edition).pre_withdrawal_issues
      expect(issues).to have_issue(:public_explanation, :blank)
    end

    it "returns an issue if there is invalid govspeak in the public explanation" do
      explanation = "<script>alert('123')</script>"
      issues = Requirements::WithdrawalChecker.new(explanation, edition).pre_withdrawal_issues
      expect(issues).to have_issue(:public_explanation, :invalid_govspeak)
    end
  end
end
