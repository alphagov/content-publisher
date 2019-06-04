# frozen_string_literal: true

RSpec.describe Requirements::ScheduledDatetimeChecker do
  include ActiveSupport::Testing::TimeHelpers

  describe "#pre_submit_issues" do
    it "returns no issues if there are none" do
      tomorrow = Time.zone.tomorrow
      issues = Requirements::ScheduledDatetimeChecker.new(
        date: { day: tomorrow.day, month: tomorrow.month, year: tomorrow.year },
        time: "11:00am",
      ).pre_submit_issues

      expect(issues.items).to be_empty
    end

    it "returns an issue if the date or time fields are blank" do
      issues = Requirements::ScheduledDatetimeChecker.new({}).pre_submit_issues

      invalid_date = I18n.t!("requirements.scheduled_date.invalid.form_message")
      invalid_time = I18n.t!("requirements.scheduled_time.invalid.form_message")

      expect(issues.items_for(:scheduled_date))
        .to include(a_hash_including(text: invalid_date))

      expect(issues.items_for(:scheduled_time))
        .to include(a_hash_including(text: invalid_time))
    end

    it "returns an issue if a date is invalid" do
      issues = Requirements::ScheduledDatetimeChecker.new(
        date: { day: 10, month: 60, year: 11 },
        time: "11:00am",
      ).pre_submit_issues

      invalid_date = I18n.t!("requirements.scheduled_date.invalid.form_message")

      expect(issues.items_for(:scheduled_date))
        .to include(a_hash_including(text: invalid_date))
    end

    it "returns an issue if a time is invalid" do
      tomorrow = Time.zone.tomorrow
      issues = Requirements::ScheduledDatetimeChecker.new(
        date: { day: tomorrow.day, month: tomorrow.month, year: tomorrow.year },
        time: "1223456",
      ).pre_submit_issues

      invalid_time = I18n.t!("requirements.scheduled_time.invalid.form_message")

      expect(issues.items_for(:scheduled_time))
        .to include(a_hash_including(text: invalid_time))
    end

    it "returns a date issue if the date is in the past" do
      two_days_ago = Time.current - 2.days

      issues = Requirements::ScheduledDatetimeChecker.new(
        date: { day: two_days_ago.day,
                month: two_days_ago.month,
                year: two_days_ago.year },
        time: "10:00am",
      ).pre_submit_issues

      past_date = I18n.t!("requirements.scheduled_date.in_the_past.form_message")

      expect(issues.items_for(:scheduled_date))
        .to include(a_hash_including(text: past_date))
    end

    it "returns a time issue if the date is present but time in the past" do
      travel_to('2019-01-01 11:00am') do
        issues = Requirements::ScheduledDatetimeChecker.new(
          date: { day: 1, month: 1, year: 2019 },
          time: "10:45am",
        ).pre_submit_issues

        past_time = I18n.t!("requirements.scheduled_time.in_the_past.form_message")

        expect(issues.items_for(:scheduled_time))
          .to include(a_hash_including(text: past_time))
      end
    end

    it "returns an issue if the datetime is too close to now" do
      travel_to('2019-01-01 11:00am') do
        issues = Requirements::ScheduledDatetimeChecker.new(
          date: { day: 1, month: 1, year: 2019 },
          time: "11:10am",
        ).pre_submit_issues

        close_time = I18n.t!("requirements.scheduled_time.too_close_to_now.form_message",
                             time_period: "15 minutes")

        expect(issues.items_for(:scheduled_time))
          .to include(a_hash_including(text: close_time))
      end
    end

    it "returns an issue if the datetime is too far into the future" do
      time_period = { days: 1, months: 14 }
      future_date = Time.current.advance(time_period)

      issues = Requirements::ScheduledDatetimeChecker.new(
        date: { day: future_date.day,
                month: future_date.month,
                year: future_date.year },
        time: "10:50am",
      ).pre_submit_issues

      too_far_in_future = I18n.t!("requirements.scheduled_date.too_far_in_future.form_message",
                               time_period: "14 months")

      expect(issues.items_for(:scheduled_date))
        .to include(a_hash_including(text: too_far_in_future))
    end
  end
end
