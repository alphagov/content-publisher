# frozen_string_literal: true

module ScheduledDatetimeHelper
  def scheduled_date(datetime)
    datetime&.strftime("%-d %B %Y")
  end

  def scheduled_time(datetime)
    datetime&.strftime("%l:%M%P")
  end
end
