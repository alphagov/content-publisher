# frozen_string_literal: true

RSpec.describe Requirements::WithdrawalChecker do
  describe "#pre_withdrawal_issues" do
    it "returns no issues if there are none" do
      public_explanation = SecureRandom.alphanumeric
      issues = Requirements::WithdrawalChecker.new(public_explanation).pre_withdrawal_issues
      expect(issues.items).to be_empty
    end

    it "returns an issue if there is no public explanation" do
      issues = Requirements::WithdrawalChecker.new(nil).pre_withdrawal_issues

      message = issues.items_for(:public_explanation).first[:text]
      expect(message).to eq(I18n.t!("requirements.public_explanation.blank.form_message"))
    end
  end
end
