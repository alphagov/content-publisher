# frozen_string_literal: true

RSpec.describe DatetimeParser do
  describe "#parse" do
    it "returns the parsed date/time when valid" do
      date_params = { day: "10", month: "01", year: "2019" }
      expected_time = Time.zone.local(2019, 1, 10, 0, 0)

      parser = DatetimeParser.new(date: date_params,
                                  time: "11:00am",
                                  issue_prefix: :schedule)
      expect(parser.parse).to eq expected_time.change(hour: 11)

      parser = DatetimeParser.new(date: date_params,
                                  time: "9:34",
                                  issue_prefix: :schedule)
      expect(parser.parse).to eq expected_time.change(hour: 9, min: 34)

      parser = DatetimeParser.new(date: date_params,
                                  time: "12:00",
                                  issue_prefix: :schedule)
      expect(parser.parse).to eq expected_time.change(hour: 12)

      parser = DatetimeParser.new(date: date_params,
                                  time: "12:00am",
                                  issue_prefix: :schedule)
      expect(parser.parse).to eq expected_time.change(hour: 0)

      parser = DatetimeParser.new(date: date_params,
                                  time: "6:00 pm",
                                  issue_prefix: :schedule)
      expect(parser.parse).to eq expected_time.change(hour: 18)

      parser = DatetimeParser.new(date: date_params,
                                  time: "23:32",
                                  issue_prefix: :schedule)
      expect(parser.parse).to eq expected_time.change(hour: 23, min: 32)

      parser = DatetimeParser.new(date: date_params,
                                  time: "12:30pm",
                                  issue_prefix: :schedule)
      expect(parser.parse).to eq expected_time.change(hour: 12, min: 30)
    end

    it "returns nil when the date/time is blank" do
      parser = DatetimeParser.new(date: nil, time: nil, issue_prefix: :schedule)
      expect(parser.parse).to be_nil
    end

    it "returns nil when the date is invalid" do
      params = { date: { day: "10", month: "60", year: "11" },
                 time: "10:00",
                 issue_prefix: :schedule }
      expect(DatetimeParser.new(params).parse).to be_nil
    end

    it "returns nil when the time is invalid" do
      params = { date: { day: "10", month: "1", year: "2019" },
                 time: "13421",
                 issue_prefix: :schedule }
      expect(DatetimeParser.new(params).parse).to be_nil
    end
  end

  describe "#issues" do
    it "returns no issues when there are none" do
      params = { date: { day: "10", month: "1", year: "2019" },
                 time: "10:00",
                 issue_prefix: :schedule }
      parser = DatetimeParser.new(params)
      parser.parse

      expect(parser.issues.items).to be_empty
    end

    it "returns issues when the date/time are blank" do
      parser = DatetimeParser.new(date: nil, time: nil, issue_prefix: :schedule)
      parser.parse

      date_form_message = parser.issues.items_for(:schedule_date).first[:text]
      expect(date_form_message).to eq(
        I18n.t!("requirements.schedule_date.invalid.form_message"),
      )

      time_form_message = parser.issues.items_for(:schedule_time).first[:text]
      expect(time_form_message).to eq(
        I18n.t!("requirements.schedule_time.invalid.form_message"),
      )
    end

    it "returns an issue when the date is invalid" do
      params = { date: { day: "10", month: "60", year: "11" },
                 time: "10:00",
                 issue_prefix: :schedule }
      parser = DatetimeParser.new(params)
      parser.parse

      form_message = parser.issues.items_for(:schedule_date).first[:text]
      expect(form_message).to eq(
        I18n.t!("requirements.schedule_date.invalid.form_message"),
      )
    end

    it "returns an issue when the time is invalid" do
      params = { date: { day: "10", month: "1", year: "2019" },
                 time: "-1:00",
                 issue_prefix: :schedule }
      parser = DatetimeParser.new(params)
      parser.parse

      form_message = parser.issues.items_for(:schedule_time).first[:text]
      expect(form_message).to eq(
        I18n.t!("requirements.schedule_time.invalid.form_message"),
      )
    end
  end
end
