# frozen_string_literal: true

module TimeOptionsHelper
  DEFAULT_PUBLISHING_TIME = "9:00am"

  def time_options(selected = nil)
    options = times.map { |time| { text: time, value: time } }
    options.each do |option|
      if option[:text] == (selected || DEFAULT_PUBLISHING_TIME)
        option[:selected] = true
        break
      end
    end
    options
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
