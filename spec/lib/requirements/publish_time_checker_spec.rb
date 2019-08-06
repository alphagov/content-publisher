# frozen_string_literal: true

RSpec.describe Requirements::PublishTimeChecker do
  include ActiveSupport::Testing::TimeHelpers

  describe "#issues" do
    it "returns no issues if there are none" do
      issues = Requirements::PublishTimeChecker.new(1.day.from_now).issues
      expect(issues).to be_empty
    end

    it "returns a date issue if the date is in the past" do
      issues = Requirements::PublishTimeChecker.new(1.day.ago).issues
      expect(issues).to have_issue(:schedule_date, :in_the_past, styles: %i[form summary])
    end

    it "returns a time issue if just the time is in the past" do
      travel_to(Time.zone.parse("2019-06-17 15:00")) do
        issues = Requirements::PublishTimeChecker.new(1.hour.ago).issues
        expect(issues).to have_issue(:schedule_time, :in_the_past, styles: %i[form summary])
      end
    end

    it "returns an issue if the time is too close to now" do
      issues = Requirements::PublishTimeChecker.new(5.minutes.from_now).issues

      expect(issues).to have_issue(:schedule_time,
                                   :too_close_to_now,
                                   styles: %i[form summary],
                                   time_period: "15 minutes")
    end

    it "returns an issue if the date is too far into the future" do
      issues = Requirements::PublishTimeChecker.new(10.years.from_now).issues

      expect(issues).to have_issue(:schedule_date,
                                   :too_far_in_future,
                                   time_period: "14 months")
    end
  end
end
