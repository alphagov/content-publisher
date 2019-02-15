# frozen_string_literal: true

RSpec.describe Requirements::ScheduledDatetimeChecker do
  let(:valid_datetime) { Time.zone.now.tomorrow }
  let(:datetime_params) do
    {
      day: valid_datetime.day,
      month: valid_datetime.month,
      year: valid_datetime.year,
      time: "11:00am",
    }
  end

  describe "#date_issues" do
    it "returns no issues if there are none" do
      issues = Requirements::ScheduledDatetimeChecker.new(datetime_params).date_issues
      expect(issues.items).to be_empty
    end

    it "returns an issue if the date is invalid" do
      datetime_params[:day] = ""
      datetime_params[:month] = ""
      datetime_params[:year] = ""

      invalid_date = I18n.t!(
        "requirements.scheduled_datetime.invalid.form_message",
        field: "Date",
      )

      issues = Requirements::ScheduledDatetimeChecker.new(datetime_params).date_issues
      expect(issues.items_for(:scheduled_datetime))
        .to include(a_hash_including(text: invalid_date))
    end
  end

  describe "#time_issues" do
    it "returns no issues if there are none" do
      issues = Requirements::ScheduledDatetimeChecker.new(datetime_params).time_issues
      expect(issues.items).to be_empty
    end

    it "returns an issue if the time values are invalid" do
      datetime_params[:time] = ""

      issues = Requirements::ScheduledDatetimeChecker.new(datetime_params).time_issues
      time_issue = I18n.t!(
        "requirements.scheduled_datetime.invalid.form_message",
        field: "Time",
      )

      expect(issues.items_for(:scheduled_datetime))
        .to include(a_hash_including(text: time_issue))
    end
  end

  describe "#datetime_issues" do
    it "returns no issues if the datetime is in the future within the limit" do
      issues = Requirements::ScheduledDatetimeChecker.new(datetime_params).datetime_issues
      expect(issues.items).to be_empty
    end

    it "returns an issue if the datetime is in the past" do
      datetime_params[:day] -= 2
      issues = Requirements::ScheduledDatetimeChecker.new(datetime_params).datetime_issues
      datetime_issue = I18n.t!("requirements.scheduled_datetime.in_the_past.form_message")

      expect(issues.items_for(:scheduled_datetime))
        .to include(a_hash_including(text: datetime_issue))
    end

    it "returns an issues if the datetime is too far in the future" do
      allowed_time_period = Requirements::ScheduledDatetimeChecker::FUTURE_TIME_PERIOD
      period = { day: 1 }.merge(allowed_time_period)
      future_date_time = valid_datetime.advance(period)

      datetime_params[:day] = future_date_time.day.to_i
      datetime_params[:month] = future_date_time.month.to_i
      datetime_params[:year] = future_date_time.year.to_i

      issues = Requirements::ScheduledDatetimeChecker.new(datetime_params).datetime_issues
      datetime_issue = I18n.t!("requirements.scheduled_datetime.too_far_in_future.form_message",
                               time_period: allowed_time_period.map { |k, v| "#{v} #{k}" }.join(" & "))

      expect(issues.items_for(:scheduled_datetime))
        .to include(a_hash_including(text: datetime_issue))
    end
  end

  describe "#pre_submit_issues" do
    it "returns no issues if there are none" do
      issues = Requirements::ScheduledDatetimeChecker.new(datetime_params).pre_submit_issues
      expect(issues.items).to be_empty
    end

    it "returns datetime issues if any are present" do
      datetime_params[:day] -= 2
      datetime_issue = I18n.t!("requirements.scheduled_datetime.in_the_past.form_message")

      issues = Requirements::ScheduledDatetimeChecker.new(datetime_params).pre_submit_issues

      expect(issues.items_for(:scheduled_datetime))
        .to include(a_hash_including(text: datetime_issue))
    end

    it "returns date and time issues if any are present" do
      datetime_params[:day] = ""
      datetime_params[:time] = ""

      date_issue = I18n.t!(
        "requirements.scheduled_datetime.invalid.form_message",
        field: "Date",
      )

      time_issue = I18n.t!(
        "requirements.scheduled_datetime.invalid.form_message",
        field: "Time",
      )

      issues = Requirements::ScheduledDatetimeChecker.new(datetime_params).pre_submit_issues

      expect(issues.items_for(:scheduled_datetime))
      .to include(a_hash_including(text: date_issue))
      expect(issues.items_for(:scheduled_datetime))
        .to include(a_hash_including(text: time_issue))
    end
  end
end
