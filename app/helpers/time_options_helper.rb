# frozen_string_literal: true

module TimeOptionsHelper
  DEFAULT_PUBLISHING_TIME = "9:00am"

  def time_options(selected = nil)
    options = times.map { |time| [time, time] }
    selected_options = times.map { |time| [time, time] if time == (selected || DEFAULT_PUBLISHING_TIME) }.compact
    options_for_select = { options: options, selected_options: selected_options }
    options_for_select
  end

private

  def times
    hours = [12] + (1..11).to_a
    incremented_hours = hours.map do |hour|
      [hour.to_s + ":00", hour.to_s + ":30"]
    end

    meridiem_hours = incremented_hours.flatten!.map { |hour| hour + "am" }
    incremented_hours.each { |hour| meridiem_hours << hour + "pm" }
    meridiem_hours[0] = "12:01am"
    meridiem_hours
  end
end
