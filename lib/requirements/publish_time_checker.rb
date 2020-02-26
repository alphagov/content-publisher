module Requirements
  class PublishTimeChecker
    include ActionView::Helpers::DateHelper

    MAX_PUBLISH_DELAY = 14.months
    MIN_PUBLISH_DELAY = 15.minutes

    def issues(publish_time)
      issues = CheckerIssues.new

      if publish_time > MAX_PUBLISH_DELAY.from_now
        issues.create(:schedule_date,
                      :too_far_in_future,
                      time_period: MAX_PUBLISH_DELAY.inspect)
      end

      if publish_time > Time.zone.now && publish_time < MIN_PUBLISH_DELAY.from_now
        issues.create(:schedule_time,
                      :too_close_to_now,
                      time_period: MIN_PUBLISH_DELAY.inspect)
      end

      if publish_time < Time.zone.now
        field = publish_time.today? ? :schedule_time : :schedule_date
        issues.create(field, :in_the_past)
      end

      issues
    end
  end
end
