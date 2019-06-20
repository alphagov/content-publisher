# frozen_string_literal: true

RSpec.describe DateParser do
  describe "#parse" do
    it "returns the parsed date when valid" do
      params = { day: "10", month: "01", year: "2019" }
      expected_date = Time.zone.local(2019, 1, 10, 0, 0)

      datetime = DateParser.new(date: params, issue_prefix: :backdate).parse
      expect(datetime).to eq(expected_date)
    end

    it "returns nil when the date is blank" do
      expect(DateParser.new(date: nil, issue_prefix: :backdate).parse).to be_nil
    end

    it "returns nil when the date is invalid" do
      params = { day: "10", month: "60", year: "11" }
      expect(DateParser.new(date: params, issue_prefix: :backdate).parse).to be_nil
    end
  end

  describe "#issues" do
    it "returns no issues when there are none" do
      params = { day: "10", month: "1", year: "2019" }
      parser = DateParser.new(date: params, issue_prefix: :backdate)
      parser.parse

      expect(parser.issues.items).to be_empty
    end

    it "returns issues when the date is blank" do
      parser = DateParser.new(date: nil, issue_prefix: :backdate)
      parser.parse

      date_form_message = parser.issues.items_for(:backdate_date).first[:text]
      expect(date_form_message).to eq(I18n.t!("requirements.backdate_date.invalid.form_message"))
    end

    it "returns an issue when the date is invalid" do
      params = { day: "10", month: "60", year: "11" }
      parser = DateParser.new(date: params, issue_prefix: :backdate)
      parser.parse

      form_message = parser.issues.items_for(:backdate_date).first[:text]
      expect(form_message).to eq(I18n.t!("requirements.backdate_date.invalid.form_message"))
    end
  end
end
