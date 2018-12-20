# frozen_string_literal: true

RSpec.describe Requirements::PublicExplanationChecker do
  describe "#pre_withdrawal_issues" do
    let(:max_length) { Requirements::PublicExplanationChecker::PUBLIC_EXPLANATION_MAX_LENGTH }

    it "returns no issues if there are none" do
      public_explanation = "a" * max_length
      issues = Requirements::PublicExplanationChecker.new(public_explanation).pre_withdrawal_issues
      expect(issues.items).to be_empty
    end

    it "returns an issue if there is no public explanation" do
      issues = Requirements::PublicExplanationChecker.new(nil).pre_withdrawal_issues

      message = issues.items_for(:public_explanation).first[:text]
      expect(message).to eq(I18n.t!("requirements.public_explanation.blank.form_message"))
    end

    it "returns an issue if the public explanation is too long" do
      public_explanation = "a" * (max_length + 1)
      issues = Requirements::PublicExplanationChecker.new(public_explanation).pre_withdrawal_issues

      message = issues.items_for(:public_explanation).first[:text]
      expect(message).to eq(I18n.t!("requirements.public_explanation.too_long.form_message", max_length: max_length))
    end
  end
end
