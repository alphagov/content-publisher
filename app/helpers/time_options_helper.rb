# frozen_string_literal: true

module TimeOptionsHelper
  def time_options(additional_time = nil)
    match = additional_time&.match(%r{\A(?<hour>\d{1,2}):(?<minute>\d{1,2})(?<period>(am|pm))\Z})

    %w[am pm].flat_map do |period|
      hours = [12] + (1..11).to_a
      hours.flat_map do |hour|
        intervals = if hour == 12 && period == "am"
                      ["12:01am", "12:30am"]
                    else
                      ["#{hour}:00#{period}", "#{hour}:30#{period}"]
                    end

        if match && match[:hour].to_i == hour && match[:period] == period
          intervals << additional_time
        end

        intervals.uniq.sort
      end
    end
  end
end
