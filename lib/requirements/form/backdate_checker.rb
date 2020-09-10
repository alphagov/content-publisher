class Requirements::Form::BackdateChecker < Requirements::Checker
  EARLIEST_DATE = Date.new(1995, 1, 1)

  attr_reader :backdate

  def initialize(backdate, **)
    @backdate = backdate
  end

  def check
    if backdate > Time.zone.today
      issues.create(:backdate_date, :in_the_future)
    end

    if backdate < EARLIEST_DATE
      date = EARLIEST_DATE.strftime("%-d %B %Y")
      issues.create(:backdate_date, :too_long_ago, date: date)
    end
  end
end
