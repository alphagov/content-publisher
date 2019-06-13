# frozen_string_literal: true

RSpec.describe Requirements::ScheduleDatetimeChecker do
  include ActiveSupport::Testing::TimeHelpers

  describe "#pre_submit_issues" do
    it "returns no issues if there are none" do
      tomorrow = Time.zone.tomorrow
      issues = Requirements::ScheduleDatetimeChecker.new(
        date: { day: tomorrow.day, month: tomorrow.month, year: tomorrow.year },
        time: "11:00am",
      ).pre_submit_issues

      expect(issues.items).to be_empty
    end

    it "returns an issue if the date or time fields are blank" do
      issues = Requirements::ScheduleDatetimeChecker.new({}).pre_submit_issues

      invalid_date = I18n.t!("requirements.schedule_date.invalid.form_message")
      invalid_time = I18n.t!("requirements.schedule_time.invalid.form_message")

      expect(issues.items_for(:schedule_date))
        .to include(a_hash_including(text: invalid_date))

      expect(issues.items_for(:schedule_time))
        .to include(a_hash_including(text: invalid_time))
    end

    it "returns an issue if a date is invalid" do
      issues = Requirements::ScheduleDatetimeChecker.new(
        date: { day: 10, month: 60, year: 11 },
        time: "11:00am",
      ).pre_submit_issues

      invalid_date = I18n.t!("requirements.schedule_date.invalid.form_message")

      expect(issues.items_for(:schedule_date))
        .to include(a_hash_including(text: invalid_date))
    end

    it "returns an issue if a time is invalid" do
      travel_to("2019-01-01 11:00am") do
        date_options = { day: 2, month: 1, year: 2019 }
        invalid_time_message = I18n.t!("requirements.schedule_time.invalid.form_message")

        invalid_time_issues = a_hash_including(text: invalid_time_message)

        checker = Requirements::ScheduleDatetimeChecker.new(time: "123456",
                                                             date: date_options)
        expect(checker.pre_submit_issues.items_for(:schedule_time))
          .to include(invalid_time_issues)

        checker = Requirements::ScheduleDatetimeChecker.new(time: "12:34:56",
                                                             date: date_options)
        expect(checker.pre_submit_issues.items_for(:schedule_time))
          .to include(invalid_time_issues)

        checker = Requirements::ScheduleDatetimeChecker.new(time: "12:34 +0100",
                                                             date: date_options)
        expect(checker.pre_submit_issues.items_for(:schedule_time))
          .to include(invalid_time_issues)

        checker = Requirements::ScheduleDatetimeChecker.new(time: "2019-04-01",
                                                             date: date_options)
        expect(checker.pre_submit_issues.items_for(:schedule_time))
          .to include(invalid_time_issues)
      end
    end

    it "accepts times formatted different from how we present them" do
      travel_to("2019-01-01 11:00am") do
        date_options = { day: 2, month: 1, year: 2019 }

        checker = Requirements::ScheduleDatetimeChecker.new(time: "9:34",
                                                             date: date_options)
        expect(checker.pre_submit_issues.items).to be_empty
        expect(checker.parsed_datetime).to eql(Time.zone.parse("2019-01-02 09:34"))

        checker = Requirements::ScheduleDatetimeChecker.new(time: "12:00",
                                                             date: date_options)
        expect(checker.pre_submit_issues.items).to be_empty
        expect(checker.parsed_datetime).to eql(Time.zone.parse("2019-01-02 12:00"))

        checker = Requirements::ScheduleDatetimeChecker.new(time: "12:00am",
                                                             date: date_options)
        expect(checker.pre_submit_issues.items).to be_empty
        expect(checker.parsed_datetime).to eql(Time.zone.parse("2019-01-02 0:00"))

        checker = Requirements::ScheduleDatetimeChecker.new(time: "6:00 pm",
                                                             date: date_options)
        expect(checker.pre_submit_issues.items).to be_empty
        expect(checker.parsed_datetime).to eql(Time.zone.parse("2019-01-02 18:00"))

        checker = Requirements::ScheduleDatetimeChecker.new(time: "23:32",
                                                             date: date_options)
        expect(checker.pre_submit_issues.items).to be_empty
        expect(checker.parsed_datetime).to eql(Time.zone.parse("2019-01-02 23:32"))

        checker = Requirements::ScheduleDatetimeChecker.new(time: "12:30pm",
                                                             date: date_options)
        expect(checker.pre_submit_issues.items).to be_empty
        expect(checker.parsed_datetime).to eql(Time.zone.parse("2019-01-02 12:30"))
      end
    end

    it "returns a date issue if the date is in the past" do
      two_days_ago = Time.current - 2.days

      issues = Requirements::ScheduleDatetimeChecker.new(
        date: { day: two_days_ago.day,
                month: two_days_ago.month,
                year: two_days_ago.year },
        time: "10:00am",
      ).pre_submit_issues

      past_date = I18n.t!("requirements.schedule_date.in_the_past.form_message")

      expect(issues.items_for(:schedule_date))
        .to include(a_hash_including(text: past_date))
    end

    it "returns a time issue if the date is present but time in the past" do
      travel_to("2019-01-01 11:00am") do
        issues = Requirements::ScheduleDatetimeChecker.new(
          date: { day: 1, month: 1, year: 2019 },
          time: "10:45am",
        ).pre_submit_issues

        past_time = I18n.t!("requirements.schedule_time.in_the_past.form_message")

        expect(issues.items_for(:schedule_time))
          .to include(a_hash_including(text: past_time))
      end
    end

    it "returns an issue if the datetime is too close to now" do
      travel_to("2019-01-01 11:00am") do
        issues = Requirements::ScheduleDatetimeChecker.new(
          date: { day: 1, month: 1, year: 2019 },
          time: "11:10am",
        ).pre_submit_issues

        close_time = I18n.t!("requirements.schedule_time.too_close_to_now.form_message",
                             time_period: "15 minutes")

        expect(issues.items_for(:schedule_time))
          .to include(a_hash_including(text: close_time))
      end
    end

    it "returns an issue if the datetime is too far into the future" do
      time_period = { days: 1, months: 14 }
      future_date = Time.current.advance(time_period)

      issues = Requirements::ScheduleDatetimeChecker.new(
        date: { day: future_date.day,
                month: future_date.month,
                year: future_date.year },
        time: "10:50am",
      ).pre_submit_issues

      too_far_in_future = I18n.t!("requirements.schedule_date.too_far_in_future.form_message",
                                  time_period: "14 months")

      expect(issues.items_for(:schedule_date))
        .to include(a_hash_including(text: too_far_in_future))
    end
  end
end
