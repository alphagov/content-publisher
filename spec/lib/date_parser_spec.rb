RSpec.describe DateParser do
  describe "#parse" do
    it "returns the parsed date when valid" do
      params = { day: "10", month: "01", year: "2019" }
      expected_date = Time.zone.local(2019, 1, 10, 0, 0)

      datetime = described_class.new(date: params, issue_prefix: :backdate).parse
      expect(datetime).to eq(expected_date)
    end

    it "returns nil when the date is blank" do
      expect(described_class.new(date: nil, issue_prefix: :backdate).parse).to be_nil
    end

    it "returns nil when the date is invalid" do
      params = { day: "10", month: "60", year: "11" }
      expect(described_class.new(date: params, issue_prefix: :backdate).parse).to be_nil
    end
  end

  describe "#issues" do
    it "returns no issues when there are none" do
      params = { day: "10", month: "1", year: "2019" }
      parser = described_class.new(date: params, issue_prefix: :backdate)

      parser.parse
      expect(parser.issues.items).to be_empty
    end

    it "returns issues when the date is blank" do
      parser = described_class.new(date: nil, issue_prefix: :backdate)
      parser.parse
      expect(parser.issues).to have_issue(:backdate_date, :invalid)
    end

    it "returns an issue when the date is invalid" do
      params = { day: "10", month: "60", year: "11" }
      parser = described_class.new(date: params, issue_prefix: :backdate)

      parser.parse
      expect(parser.issues).to have_issue(:backdate_date, :invalid)
    end
  end
end
