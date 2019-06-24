# frozen_string_literal: true

module DateTimeHelper
  def format_date(datetime)
    datetime.strftime("%-d %B %Y")
  end

  def format_time(datetime)
    datetime.strftime("%-l:%M%P")
  end
end
