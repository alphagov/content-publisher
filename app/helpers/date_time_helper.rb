# frozen_string_literal: true

module DateTimeHelper
  def format_date(datetime)
    datetime.strftime("%-d %B %Y")
  end

  def format_time(datetime)
    datetime.strftime("%-l:%M%P")
  end

  def format_date_at_time(datetime)
    datetime.strftime("%-d %B %Y at %-l:%M%P")
  end

  def format_time_on_date(datetime)
    datetime.strftime("%-l:%M%P on %-d %B %Y")
  end
end
