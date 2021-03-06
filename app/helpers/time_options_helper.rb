module TimeOptionsHelper
  def time_options
    %w[am pm].flat_map do |period|
      hours = [12] + (1..11).to_a
      hours.flat_map do |hour|
        next ["12:01am", "12:30am"] if hour == 12 && period == "am"

        ["#{hour}:00#{period}", "#{hour}:30#{period}"]
      end
    end
  end
end
