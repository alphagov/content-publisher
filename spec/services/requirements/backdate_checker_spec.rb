# frozen_string_literal: true

RSpec.describe Requirements::BackdateChecker do
  describe "#pre_submit_issues" do
    it "returns no issues if there are none" do
      params = { day: 1, month: 1, year: 2019 }
      issues = Requirements::BackdateChecker.new(params).pre_submit_issues

      expect(issues.items).to be_empty
    end

    it "returns an issue if the date is in the future" do
      params = { day: 1, month: 1, year: 2020 }
      issues = Requirements::BackdateChecker.new(params).pre_submit_issues
      future_date_issue = I18n.t!("requirements.backdate_date.in_the_future.form_message")

      expect(issues.items_for(:backdate_date))
        .to include(a_hash_including(text: future_date_issue))
    end

    it "returns an issue if the date is invalid" do
      invalid_params = { day: 1, month: 15, year: 2019 }
      invalid_date_issue = I18n.t!("requirements.backdate_date.invalid.form_message")

      issues = Requirements::BackdateChecker.new(invalid_params).pre_submit_issues

      expect(issues.items_for(:backdate_date))
        .to include(a_hash_including(text: invalid_date_issue))

      non_numerical_params = { day: "first", month: 1, year: 2019 }

      issues = Requirements::BackdateChecker.new(non_numerical_params).pre_submit_issues

      expect(issues.items_for(:backdate_date))
        .to include(a_hash_including(text: invalid_date_issue))
    end

    it "returns an issue if the date fields are blank" do
      invalid_date_issue = I18n.t!("requirements.backdate_date.invalid.form_message")
      issues = Requirements::BackdateChecker.new({}).pre_submit_issues

      expect(issues.items_for(:backdate_date))
        .to include(a_hash_including(text: invalid_date_issue))
    end
  end
end
