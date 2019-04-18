# frozen_string_literal: true

module TimeOptionsHelper
  DEFAULT_PUBLISHING_TIME = "9:00am"

  def time_options(selected = nil)
    extended_times = extend_times_with_selection(times, selected)
    options = extended_times.map { |time| [time, time] }
    selected_options = extended_times.select { |time| time == (selected || DEFAULT_PUBLISHING_TIME) }.compact
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

  def extend_times_with_selection(times, selected)
    if times && selected
      position = 0
      selected_meridiem = selected.chars.last(2).join
      times.each_with_index do |time, index|
        time_meridiem = time.chars.last(2).join
        position = index if selected < time && time_meridiem == selected_meridiem && !position
      end
      times.insert(position, selected)
    end
    times
  end
end
