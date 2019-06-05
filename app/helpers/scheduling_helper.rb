# frozen_string_literal: true

module SchedulingHelper
  def format_scheduled_date(datetime)
    datetime&.strftime("%-d %B %Y")
  end

  def format_scheduled_time(datetime)
    datetime&.strftime("%l:%M%P")
  end
end
