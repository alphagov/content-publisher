# frozen_string_literal: true

RSpec.describe Requirements::ScheduleChecker do
  describe "#pre_schedule_issues" do
    it "returns no issues if there are none" do
      revision = build(:revision, scheduled_publishing_datetime: 1.day.from_now)
      issues = Requirements::ScheduleChecker.new(revision).pre_schedule_issues
      expect(issues.items).to be_empty
    end

    it "returns a date issue if the date is in the past" do
      revision = build(:revision, scheduled_publishing_datetime: 1.day.ago)
      issues = Requirements::ScheduleChecker.new(revision).pre_schedule_issues

      form_message = issues.items_for(:schedule_date).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.schedule_date.in_the_past.form_message"))

      summary_message = issues.items_for(:schedule_date, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.schedule_date.in_the_past.summary_message"))
    end

    it "returns a time issue if just the time is in the past" do
      revision = build(:revision, scheduled_publishing_datetime: 1.hour.ago)
      issues = Requirements::ScheduleChecker.new(revision).pre_schedule_issues

      form_message = issues.items_for(:schedule_time).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.schedule_time.in_the_past.form_message"))

      summary_message = issues.items_for(:schedule_time, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.schedule_time.in_the_past.summary_message"))
    end

    it "returns an issue if the time is too close to now" do
      revision = build(:revision, scheduled_publishing_datetime: 5.minutes.from_now)
      issues = Requirements::ScheduleChecker.new(revision).pre_schedule_issues

      form_message = issues.items_for(:schedule_time).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.schedule_time.too_close_to_now.form_message",
                                         time_period: "15 minutes"))

      summary_message = issues.items_for(:schedule_time, style: "summary").first[:text]
      expect(summary_message).to eq(I18n.t!("requirements.schedule_time.too_close_to_now.summary_message",
                                            time_period: "15 minutes"))
    end

    it "returns an issue if the date is too far into the future" do
      revision = build(:revision, scheduled_publishing_datetime: 10.years.from_now)
      issues = Requirements::ScheduleChecker.new(revision).pre_schedule_issues

      form_message = issues.items_for(:schedule_date).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.schedule_date.too_far_in_future.form_message",
                                         time_period: "14 months"))
    end
  end
end
