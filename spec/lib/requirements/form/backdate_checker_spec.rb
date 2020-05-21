RSpec.describe Requirements::Form::BackdateChecker do
  describe ".call" do
    it "returns no issues if there are none" do
      date = Time.zone.now.change(day: 1, month: 1, year: 2019)
      issues = described_class.call(date)
      expect(issues).to be_empty
    end

    it "returns an issue if the date is in the future" do
      date = 1.year.from_now
      issues = described_class.call(date)
      expect(issues).to have_issue(:backdate_date, :in_the_future)
    end

    it "returns an issue if the date is too long ago" do
      earliest_date = Requirements::Form::BackdateChecker::EARLIEST_DATE
      issues = described_class.call(earliest_date - 1)

      expect(issues).to have_issue(:backdate_date,
                                   :too_long_ago,
                                   date: earliest_date.strftime("%-d %B %Y"))
    end
  end
end
